module HealthDataStandards
  module Import
    module E2E
      
      # TODO: Coded Product Name, Free Text Product Name, Coded Brand Name and Free Text Brand name need to be pulled out separatelty
      #       This would mean overriding extract_codes
      # TODO: Patient Instructions needs to be implemented. Will likely be a reference to the narrative section
      # TODO: Couldn't find an example medication reaction. Isn't clear to me how it should be implemented from the specs, so
      #       reaction is not implemented.
      # TODO: Couldn't find an example dose indicator. Isn't clear to me how it should be implemented from the specs, so
      #       dose indicator is not implemented.
      # TODO: Fill Status is not implemented. Couldn't figure out which entryRelationship it should be nested in
      class MedicationImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.19.1' and cda:code/@code='10160-6']/cda:entry/cda:substanceAdministration"
          @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
          @description_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:name/text()"
          #@type_of_med_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.8.1']/cda:code"
          #@indication_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.28']/cda:code"
          #@vehicle_xpath = "cda:participant/cda:participantRole[cda:code/@code='412307009' and cda:code/@codeSystem='2.16.840.1.113883.6.96']/cda:playingEntity/cda:code"
          #@fill_number_xpath = "./cda:entryRelationship[@typeCode='COMP']/cda:sequenceNumber/@value"
          @check_for_usable = true               # Pilot tools will set this to false
        end
        
        def create_entry(entry_element, id_map={})
          medication = Medication.new
          extract_codes(entry_element, medication)
          extract_dates(entry_element, medication)
          extract_description(entry_element, medication)
          
          if medication.description.present?
            medication.free_text = medication.description
          end
          
          medication
        end

        private

        def extract_description(parent_element, entry)
          code_elements = parent_element.xpath(@description_xpath)
          code_elements.each do |code_element|
            entry.description = code_element
          end
        end

      end
    end
  end
end
