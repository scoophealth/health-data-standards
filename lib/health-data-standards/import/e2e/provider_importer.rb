require "date"
# require "date/delta"

module HealthDataStandards
  module Import
    module E2E
      class ProviderImporter < SectionImporter

        def initialize

        end

        include Singleton
        include ProviderImportUtils
        # Extract Healthcare Providers from E2E
        #
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        # @return [Array] an array of providers found in the document

        # TODO: From NIST document provider in this instance seems to be taken from document header and most
        # closely corresponds to the author of E2E document
        def extract_providers(doc)
          #performers = doc.xpath("//cda:performer[cda:time and cda:assignedEntity/cda:assignedPerson and cda:assignedEntity/cda:representedOrganization]")
          performers = doc.xpath("//cda:performer[cda:time and cda:assignedEntity/cda:assignedPerson or cda:assignedEntity/cda:representedOrganization]")
          performers.map do |performer|
            provider_perf = extract_provider_data(performer, true)
            #STDERR.puts "provider_perf: "+provider_perf.inspect
            ProviderPerformance.new(start_date: provider_perf.delete(:start), end_date: provider_perf.delete(:end), provider: find_or_create_provider(provider_perf))
          end
        end

        private

        def generate_hash(the_string)
          the_hash = OpenSSL::Digest::SHA224.new
          the_hash << the_string.upcase  # need 'JOHN SMITH' to match 'John Smith', for instance
          Base64.strict_encode64(the_hash.digest)
        end

        def anonymize_provider_info(provider, print_key = false)
          anon_provider = {}
          provider_identity = ""
          the_string = ''
          if provider[:title]
            the_string += provider[:title]
          end
          if provider[:given_name]
            the_string += provider[:given_name]
            provider_identity += provider[:given_name]
          end
          if provider[:family_name]
            the_string += provider[:family_name]
            provider_identity += " " + provider[:family_name]
          end
          if provider[:specialty]
            the_string += provider[:specialty]
          end
          if provider[:npi]
            the_string += provider[:npi]
            provider_identity += ", NPI: "+provider[:npi]
          end
          anon_provider[:title] = ''
          anon_provider[:given_name] = ''
          anon_provider[:family_name] = generate_hash(the_string)
          anon_provider[:organization] = Organization.new
          anon_provider[:specialty] = ''
          anon_provider[:addresses] = []
          anon_provider[:telecoms] = []
          anon_provider[:npi] = anon_provider[:family_name]  # if empty causes creation of new entry in providers collection
          anon_provider[:start] = provider[:start]
          anon_provider[:end] = provider[:end]
          if print_key
            provider_hash = "Provider_Hash: "+anon_provider[:family_name]+ ", Provider: "+provider_identity
            if defined?(Rails.root)
              File.open("#{Rails.root}/log/Provider_Hash.txt", 'a') { |file| file.puts(provider_hash) }
            else
              File.open("/tmp/Provider_Hash.txt", 'a') { |file| file.puts(provider_hash) }
            end
          end
          anon_provider
        end

        def extract_provider_data(performer, use_dates=true)

          provider = {}
          entity = performer.xpath("./cda:assignedAuthor")
          name = entity.xpath("./cda:assignedPerson/cda:name")
          provider[:title] = extract_data(name, "./cda:prefix")
          provider[:given_name] = extract_data(name, "./cda:given")
          provider[:family_name] = extract_data(name, "./cda:family")
          provider[:organization] = OrganizationImporter.instance.extract_organization(performer.at_xpath("./cda:assignedEntity/cda:representedOrganization"))
          provider[:specialty] = extract_data(entity, "./cda:code/@code")


          time = performer.xpath(performer, "./cda:time/@value")

          if use_dates
            provider[:start] = extract_datetime(time, "./cda:low/@value")
            provider[:end] = extract_datetime(time, "./cda:high/@value")
          end

          # E2E doesn't seem to have low/high value so use value of time for both
          if provider[:start] == nil
            provider[:start] = extract_datetime(performer, "./cda:time/@value")
            if provider[:end] == nil
              provider[:end] = provider[:start]
            end
          end

          # NIST sample C32s use different OID for NPI vs C83, support both
          npi = extract_data(entity, "./cda:id[@root='2.16.840.1.113883.4.6' or @root='2.16.840.1.113883.3.72.5.2']/@extension")
          provider[:addresses] = performer.xpath("./cda:assignedEntity/cda:addr").try(:map) { |ae| import_address(ae) }
          provider[:telecoms] = performer.xpath("./cda:assignedEntity/cda:telecom").try(:map) { |te| import_telecom(te) }

          provider[:npi] = npi if Provider.valid_npi?(npi)
          provider = anonymize_provider_info(provider)
          provider
        end

        def extract_e2e_encounter_provider_data(performer, use_dates=true)
          provider = {}
          entity = performer.xpath("./cda:participant[@typeCode='PRF']/cda:participantRole")
          name = entity.xpath("./cda:playingEntity[@classCode='PSN']/cda:name")
          provider[:title] = extract_data(name, "./cda:prefix")
          provider[:given_name] = extract_data(name, "./cda:given")
          provider[:family_name] = extract_data(name, "./cda:family")
          #provider[:organization] = OrganizationImporter.instance.extract_organization(performer.at_xpath("./cda:assignedEntity/cda:representedOrganization"))
          provider[:specialty] = extract_data(entity, "./cda:code/@code")

          # returns empty time array in E2E documents seen to date
          time = performer.xpath(performer, "./cda:time/@value")
          if use_dates
            provider[:start] = extract_datetime(time, "./cda:low/@value")
            provider[:end] = extract_datetime(time, "./cda:high/@value")
          end

          # does the actual time settings in E2E documents seen to date
          if provider[:start] == nil
            provider[:start] = extract_datetime(performer, "./cda:effectiveTime/cda:low/@value")
          end

          if provider[:end] == nil
            provider[:end] = extract_datetime(performer, "./cda:effectiveTime/cda:high/@value")
          end

          # NIST sample C32s use different OID for NPI vs C83, support both
          npi = extract_data(entity, "./cda:id/@extension")

          provider[:addresses] = performer.xpath("./cda:assignedEntity/cda:addr").try(:map) { |ae| import_address(ae) }
          provider[:telecoms] = performer.xpath("./cda:assignedEntity/cda:telecom").try(:map) { |te| import_telecom(te) }

          provider[:npi] = npi # if Provider.valid_npi?(npi)
          #STDERR.puts "provider: " + provider.inspect

          # To log hash keys assigned to providers set print_key to true
          provider = anonymize_provider_info(provider, print_key=true)
          provider
        end

        def extract_e2e_medication_provider_data(performer)
          provider = {}
          name = performer.xpath("./cda:assignedAuthor/cda:assignedPerson/cda:name")
          provider[:given_name] = extract_data(name, "./cda:given")
          provider[:family_name] = extract_data(name, "./cda:family")
          if !provider[:family_name]
            # no need to parse string like "Dr. W. Pewarchuck" into given and family names as
            # it is anonymized anyway
            provider[:family_name] = name.text()
          end

          time = performer.xpath(performer, "./cda:time/@value")

          provider[:start] = extract_datetime(performer, "./cda:time/@value")

          # NIST sample C32s use different OID for NPI vs C83, support both
          npi = extract_data(performer, "./cda:assignedAuthor/cda:id/@extension")

          provider[:npi] = npi

          # To log hash keys assigned to providers set print_key to true
          provider = anonymize_provider_info(provider, print_key=true)
          provider
        end

        def find_or_create_provider(provider_hash)
          #provider = Provider.first(conditions: {npi: provider_hash[:npi]}) if provider_hash[:npi]
          provider = Provider.where(npi: provider_hash[:npi]).first if provider_hash[:npi] && !provider_hash[:npi].empty?
          #provider ||= Provider.create(provider_hash)
          #STDERR.puts "provider_hash: "+provider_hash.inspect
          if provider == nil
            provider = Provider.create(provider_hash) #new(provider_hash)
          end
          provider
        end

        # Uses DateTime rather than Date to capture time of day rather than truncate to date.
        # Will use timezone info if present so output datetime can differ from the output of
        # HL7Helper.timestamp_to_integer used in encounter importer which assumes UTC
        def extract_datetime(subject, query)
          date = extract_data(subject, query)
          #TODO address the issue of strings including timezone information properly, this just ignores
          # this informatiion which is consistent with it being ignored in other code like HL7Helper.
          date = date.split('-')[0] if date
          date ? DateTime.parse(date).to_time.to_i : nil
        end

        # Returns nil if result is an empty string, block allows text munging of result if there is one
        def extract_data(subject, query)
          result = subject.xpath(query).text
          if result == ""
            nil
          else
            result
          end
        end
      end
    end
  end
end
