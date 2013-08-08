module HealthDataStandards
  module Import
    module E2E
      class AllergyImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.4.1']/cda:entry/cda:act"
          @code_xpath = "./cda:entryRelationship/cda:observation/cda:participant/cda:participantRole/cda:playingEntity/cda:code"
          @description_xpath = "./cda:entryRelationship/cda:observation/cda:participant/cda:participantRole/cda:playingEntity/cda:name"
          @type_xpath = "./cda:code"
          #No support for reaction type (i.e., 'hives', etc.) in OSCAR E2E
          #@reaction_xpath = "./cda:entryRelationship[@typeCode='MFST']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.54']/cda:value"
          @reaction_xpath = "./cda:entryRelationship/cda:observation/cda:entryRelationship/cda:observation[cda:code/@code='REACTOBS']/cda:text"
          @severity_xpath = "./cda:entryRelationship/cda:observation/cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.3.1818.10.4.30']/cda:observation/cda:value"
          @status_xpath   = "./cda:entryRelationship/cda:observation/cda:entryRelationship/cda:observation/cda:value[@codeSystem='2.16.840.1.113883.3.1818.10.2.8.2']"
          @id_map = {}
        end

        # Traverses that PITO E2E document passed in using XPath and creates an Array of Entry
        # objects based on what it finds
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        #        measure definition
        # @return [Array] will be a list of Entry objects
        def create_entries(doc,id_map = {})
          @id_map = id_map
          allergy_list = []
          entry_elements = doc.xpath(@entry_xpath)
          entry_elements.each do |entry_element|
            #STDERR.puts "ENTRY_ELEMENT: " + entry_element.inspect
            allergy = Allergy.new
            extract_e2e_codes(entry_element, allergy)
            extract_dates(entry_element, allergy)
            extract_e2e_description(entry_element, allergy)
            extract_negation(entry_element, allergy)

            extract_e2e_status(entry_element, allergy)
            allergy.type = extract_code(entry_element, @type_xpath)
            allergy.reaction = extract_code(entry_element, @reaction_xpath)
            #STDERR.puts "reaction: "+allergy.reaction.inspect
            allergy.severity = extract_code(entry_element, @severity_xpath)
            #STDERR.puts "ENTRY_ELEMENT: " +entry_element
            #STDERR.puts "SEVERITY_XPATH: " +@severity_xpath
            #STDERR.puts "ALLERGY.SEVERITY: "+allergy.severity.inspect
            #puts "ALLERGY: " + allergy.inspect
            allergy_list << allergy
          end
          allergy_list
        end

        private

        def extract_e2e_codes(parent_element, entry)
          code_elements = parent_element.xpath(@code_xpath)
          code_elements.each do |code_element|
            add_e2e_code_if_present(code_element, entry)
          end
        end

        def add_e2e_code_if_present(code_element, entry)
          if code_element['codeSystem'] && code_element['code']
            entry.add_code(code_element['code'], CodeSystemHelper.code_system_for(code_element['codeSystem']))
          elsif code_element['nullFlavor']
            entry.add_code(code_element['nullFlavor'], 'Unknown')
          else
            STDERR.puts "CODE_ELEMENT: " + code_element.inspect
          end
        end

        def extract_e2e_description(parent_element, entry)
          code_elements = parent_element.xpath(@description_xpath)
          entry.description = code_elements.text
        end

        def extract_e2e_status(parent_element, entry)
          status_element = parent_element.at_xpath(@status_xpath)
          if status_element
            entry.status_code = {CodeSystemHelper.code_system_for(status_element['codeSystem']) => [status_element['code']]}
            #entry.status = {CodeSystemHelper.code_system_for(status_element['codeSystem']) => [status_element['code']]}
          end
        end

      end
    end
  end
end