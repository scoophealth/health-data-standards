module HealthDataStandards
  module Import
    module E2E
      class EncounterImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.12.1' and cda:code/@code='46240-8']/cda:entry/cda:encounter"
          @code_xpath = "./cda:code"
          @description_xpath = "./cda:text/text()"
          @reason_xpath = "./cda:entryRelationship/cda:observation[cda:code/@code='REASON']"
          @participant_xpath = "./cda:participant[@typeCode='LOC']/cda:participantRole[@classCode='SDLOC']"
          #@provider_xpath =    "./cda:participant[@typeCode='PRF']"
          #@provider_xpath = "./cda:entryRelationship/cda:observation[cda:code/@code='REASON']/cda:author"
          #@check_for_usable = true               # Pilot tools will set this to false
          #@id_map = {}
        end

        # Traverses the E2E document passed in using XPath and creates an Array of Entry
        # objects based on what it finds                          
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        #        measure definition
        # @return [Array] will be a list of Entry objects
        def create_entries(doc,id_map = {})
          encounter_list = []
          entry_elements = doc.xpath(@entry_xpath)
          entry_elements.each do |entry_element|
            encounter = create_entry(entry_element, id_map={})
            #if @check_for_usable
            #  encounter_list << encounter if encounter.usable?
            #else
            encounter_list << encounter
            #end
          end
          encounter_list
        end

        def create_entry(entry_element, id_map={})
          encounter = Encounter.new
          extract_codes(entry_element, encounter)
          extract_dates(entry_element, encounter)
          extract_e2e_description(entry_element, encounter)
          extract_facility(entry_element, encounter)
          extract_reason(entry_element, encounter)
          extract_performer(entry_element, encounter)
          #TODO remove this hack needed for patientapi to consider encounter usable
          if encounter.codes.size == 0
            encounter.codes = {'code' => ['REASON'], 'codeSystem' => ['ObservationType-CA-Pending']}
          end
          encounter
        end

        private

        def extract_performer(parent_element, encounter)
          encounter.performer = import_e2e_encounter_actor(parent_element) if parent_element
        end

        def import_e2e_encounter_actor(actor_element)
          return ProviderImporter.instance.extract_e2e_encounter_provider(actor_element)
        end

        def extract_e2e_codes(parent_element, entry)
          extract_codes(parent_element, entry)
          code_element = parent_element.at_xpath("./cda:value")
          if code_element
            add_code_if_present(code_element, entry)
          end
        end

        def extract_e2e_description(parent_element, entry)
          reason_element = parent_element.xpath(@reason_xpath)
          extract_description(reason_element, entry)
        end

        def extract_description(parent_element, entry)
          entry.description = parent_element.xpath(@description_xpath).to_s
        end

        def extract_facility(parent_element, encounter)
          participant_element = parent_element.at_xpath(@participant_xpath)
          if participant_element
            facility = Facility.new(name: participant_element.at_xpath("./cda:playingEntity/cda:name").try(:text))
            facility.addresses = participant_element.xpath("./cda:addr").try(:map) {|ae| import_address(ae)}
            facility.telecoms = participant_element.xpath("./cda:telecom").try(:map) {|te| import_telecom(te)}
            facility.code = extract_code(participant_element, './cda:code')
            extract_dates(participant_element.parent, facility, "time")
            encounter.facility = facility
          end
        end

        def extract_reason(parent_element, encounter)
          reason_element = parent_element.at_xpath(@reason_xpath)
          if reason_element
            reason = Entry.new
            extract_e2e_codes(reason_element, reason)
            extract_description(reason_element, reason)
            extract_status(reason_element, reason)
            extract_dates(reason_element, reason)
            encounter.reason = reason
          end
        end
      end
    end
  end
end
