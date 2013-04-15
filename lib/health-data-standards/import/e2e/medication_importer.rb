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
          @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:code"
          @description_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:name/text()"
          #@type_of_med_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.8.1']/cda:code"
          #@indication_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.28']/cda:code"
          #@vehicle_xpath = "cda:participant/cda:participantRole[cda:code/@code='412307009' and cda:code/@codeSystem='2.16.840.1.113883.6.96']/cda:playingEntity/cda:code"
          #@fill_number_xpath = "./cda:entryRelationship[@typeCode='COMP']/cda:sequenceNumber/@value"
          @check_for_usable = true               # Pilot tools will set this to false
        end
        
        def create_entry(entry_element, id_map={})
          medication = Medication.new
          extract_codes(entry_element, medication)
          #extract_dates(entry_element, medication)
          extract_description(entry_element, medication)
          
          if medication.description.present?
            medication.free_text = medication.description
          end
          
          extract_order_information(entry_element, medication)
          extract_dates(entry_element, medication)
          
          medication
        end

        private

        def extract_description(parent_element, entry)
          code_elements = parent_element.xpath(@description_xpath)
          code_elements.each do |code_element|
            entry.description = code_element
          end
        end
    
        def extract_order_information(parent_element, medication)
          order_elements = parent_element.xpath("./cda:entryRelationship[@typeCode='REFR']/cda:supply[@moodCode='INT']")
          if order_elements
            order_elements.each do |order_element|
              order_information = OrderInformation.new
              actor_element = order_element.at_xpath('./cda:author')
              if actor_element
                order_information.provider = ProviderImporter.instance.extract_provider(actor_element, "assignedAuthor")
              end
              order_information.order_number = order_element.at_xpath('./cda:id').try(:[], 'root')
              order_information.fills = order_element.at_xpath('./cda:repeatNumber').try(:[], 'value').try(:to_i)
              order_information.quantity_ordered = extract_scalar(order_element, "./cda:quantity")
          
              medication.orderInformation << order_information
            end
          end
        end

        # Find date in Medication Prescription Event. Commented out because there should be an 
        # orderinformation object created to hold the prescription dates.
        
        def extract_dates(parent_element, entry, element_name="effectiveTime")
          print "XML Node: " + parent_element.to_s + "\n"
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}")
            entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}")['value'])
          end
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:low")
            entry.start_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:low")['value'])
          end
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:high")
            entry.end_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:high")['value'])
          end
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:center")
            entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:center")['value'])
          end
          print "Codes: " + entry.codes_to_s + "\n"
          print "Time: " + entry.time.to_s + "\n"
          print "Start Time: " + entry.start_time.to_s + "\n"
          print "End Time: " + entry.end_time.to_s + "\n"
        end
      end
    end
  end
end
