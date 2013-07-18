module HealthDataStandards
  module Import
    module E2E
      class ImmunizationImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.14.1']/cda:entry/cda:substanceAdministration"
          @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
          @description_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:name"
          @check_for_usable = true               # Pilot tools will set this to false
        end

        # Traverses that E2E document passed in using XPath and creates an Array of Entry
        # objects based on what it finds
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        #        measure definition
        # @return [Array] will be a list of Entry objects
        def create_entries(doc,id_map = {})
          immunization_list = []
          entry_elements = doc.xpath(@entry_xpath)
          entry_elements.each do |entry_element|
            immunization = Immunization.new
            extract_codes(entry_element, immunization)
            extract_dates(entry_element, immunization)
            #extract_description(entry_element, immunization, id_map)
            extract_description(entry_element, immunization)
            #extract_negation(entry_element, immunization)
            #extract_performer(entry_element, immunization)
            #STDERR.puts "IMMUNIZATION: " + immunization.inspect
            #immunization_list << immunization
            if @check_for_usable
              immunization_list << immunization if immunization.usable?
            else
              immunization_list << immunization
            end
          end
          immunization_list
          #STDERR.puts "IMMUNIZATION_LIST: " + immunization_list.inspect
        end

        private

        def extract_codes(parent_element, entry)
          code_elements = parent_element.xpath(@code_xpath)
          code_elements.each do |code_element|
            #STDERR.puts code_elements.to_s
            add_code_if_present(code_element, entry)
            #translations = code_element.xpath('cda:translation')
            #translations.each do |translation|
            #  add_code_if_present(translation, entry)
            #end
          end
        end

        def add_code_if_present(code_element, entry)
          if code_element['codeSystem'] && code_element['code']
            entry.add_code(code_element['code'], CodeSystemHelper.code_system_for(code_element['codeSystem']))
          elsif code_element['nullFlavor']
            entry.add_code(code_element['nullFlavor'], 'Unknown')
          else
            STDERR.puts "CODE_ELEMENT: " + code_element.inspect
          end
        end

        def extract_description(parent_element, entry) #, id_map)
          code_elements = parent_element.xpath(@description_xpath)
          #code_elements.each do |code_element|
            #tag = code_element['value']
            #entry.description = '' #code_element['name'] #lookup_tag(tag, id_map)
          #end
          entry.description = code_elements.text
        end

      end
    end
  end
end