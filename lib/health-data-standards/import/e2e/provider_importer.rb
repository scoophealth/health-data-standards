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
            provider[:start] = extract_date(time, "./cda:low/@value")
            provider[:end] = extract_date(time, "./cda:high/@value")
          end

          # E2E doesn't seem to have low/high value so use value of time for both
          if provider[:start] == nil
            provider[:start] = extract_date(performer, "./cda:time/@value")
            if provider[:end] == nil
              provider[:end] = provider[:start]
            end
          end

          # NIST sample C32s use different OID for NPI vs C83, support both
          npi = extract_data(entity, "./cda:id[@root='2.16.840.1.113883.4.6' or @root='2.16.840.1.113883.3.72.5.2']/@extension")
          provider[:addresses] = performer.xpath("./cda:assignedEntity/cda:addr").try(:map) { |ae| import_address(ae) }
          provider[:telecoms] = performer.xpath("./cda:assignedEntity/cda:telecom").try(:map) { |te| import_telecom(te) }

          provider[:npi] = npi if Provider.valid_npi?(npi)
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
          time = performer.xpath(performer, "./cda:time/@value")

          if use_dates
            provider[:start] = extract_date(time, "./cda:low/@value")
            provider[:end] = extract_date(time, "./cda:high/@value")
          end

          # E2E doesn't seem to have low/high value so use value of time for both
          if provider[:start] == nil
            provider[:start] = extract_date(performer, "./cda:effectiveTime/@value")
            if provider[:end] == nil
              provider[:end] = provider[:start]
            end
          end

          # NIST sample C32s use different OID for NPI vs C83, support both
          npi = extract_data(entity, "./cda:id/@extension")

          provider[:addresses] = performer.xpath("./cda:assignedEntity/cda:addr").try(:map) { |ae| import_address(ae) }
          provider[:telecoms] = performer.xpath("./cda:assignedEntity/cda:telecom").try(:map) { |te| import_telecom(te) }

          provider[:npi] = npi # if Provider.valid_npi?(npi)
          #STDERR.puts "provider: " + provider.inspect
          provider
        end

        def find_or_create_provider(provider_hash)
          #provider = Provider.first(conditions: {npi: provider_hash[:npi]}) if provider_hash[:npi]
          provider = Provider.where(npi: provider_hash[:npi]).first if provider_hash[:npi] && !provider_hash[:npi].empty?
          #provider ||= Provider.create(provider_hash)
          #STDERR.puts "provider_hash: "+provider_hash.inspect
          if provider == nil
            provider = Provider.new(provider_hash)
          end
        end

        def extract_date(subject, query)
          date = extract_data(subject, query)
          date ? Date.parse(date).to_time.to_i : nil
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
