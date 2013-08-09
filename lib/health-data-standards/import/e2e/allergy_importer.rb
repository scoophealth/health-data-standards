# XPath prefix: /ClinicalDocument/component/structuredBody/component/section/entry/act
#
# OSCAR Field          Business Term              Field               XPath (suffix)
# -----------          -------------              -----               --------------
# allergyid            Record ID                  id extension        ./id/@extension
# archived             Allergy/Intolerance Status statusCode          ./statusCode/@code
# lastUpdateDate       Documented Date            effectiveTime value ./effectiveTime/@value
# start_date           Onset Date & Resolved Date effectiveTime >     ./entryRelationship/observation/effectiveTime/low/@value
#                                                      low value      ./entryRelationship/observation/entryRelationship/observation/effectiveTime/low/@value
# TYPECODE             Adverse Event Type Code    code                ./entryRelationship/observation[participant]/code/@code
# regional_identifier  Coded Allergen             code                ./entryRelationship/observation/participant/participantRole/playingEntity/code/@code
# DESCRIPTION          Free Text Allergen         name                ./entryRelationship/observation/participant/participantRole/playingEntity/name
# reaction             Reaction Name              text                ./entryRelationship/observation/entryRelationship/observation[code/@code='REACTOBS']/text
# severity_of_reaction Coded Severity Value       value code          ./entryRelationship/observation/entryRelationship/observation/value/@code
#                                                                     ./entryRelationship/observation/entryRelationship/observation/entryRelationship/observation/value/@code
# entry_date           Authored Date/Time         time value          ./entryRelationship/observation/entryRelationship/observation/author/time/@value
# life_stage           Lifestage at Onset         entryRelationship   ./entryRelationship/observation/entryRelationship/observation/value/@code
# providerNo           Reaction Author            assignedPerson      ./entryRelationship/observation/entryRelationship/observation/author/assignedAuthor/assignedPerson/name
#                                                 > name > given,family

module HealthDataStandards
  module Import
    module E2E
      class AllergyImporter < SectionImporter

        def initialize
          #@entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.4.1']/cda:entry/cda:act"
          @entry_xpath = "/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry/cda:act"
          @code_xpath = "./cda:entryRelationship/cda:observation/cda:participant/cda:participantRole/cda:playingEntity/cda:code"
          @description_xpath = "./cda:entryRelationship/cda:observation/cda:participant/cda:participantRole/cda:playingEntity/cda:name"
          @type_xpath = "./cda:entryRelationship/cda:observation[cda:participant]/cda:code"
          @reaction_xpath = "./cda:entryRelationship/cda:observation/cda:entryRelationship/cda:observation[cda:code/@code='REACTOBS']"
          #@severity_xpath = "./cda:entryRelationship/cda:observation/cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.3.1818.10.4.30']/cda:observation/cda:value"
          @severity_xpath = "./ cda:entryRelationship/cda:observation/cda:entryRelationship/cda:observation[cda:code/@code='SEV']/cda:value"
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
            allergy = Allergy.new
            extract_e2e_codes(entry_element, allergy)
            extract_dates(entry_element, allergy)
            extract_e2e_description(entry_element, allergy)
            extract_negation(entry_element, allergy)

            extract_e2e_status(entry_element, allergy)
            allergy.type = extract_e2e_type(entry_element, allergy)

            allergy.reaction = extract_e2e_reaction(entry_element, allergy)
            allergy.severity = extract_e2e_severity(entry_element, allergy)
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
          end
          entry.status_code
        end

        def extract_e2e_type(parent_element, entry)
          type_element = parent_element.xpath(@type_xpath)
          entry.type = nil
          if type_element
            element = {}
            element['code'] = parent_element.xpath(@type_xpath+"/@code").to_s
            element['displayName'] = parent_element.xpath(@type_xpath+"/@displayName").to_s
            element['codeSystem'] = parent_element.xpath(@type_xpath+"/@codeSystem").to_s
            element['codeSystemName'] = parent_element.xpath(@type_xpath+"/@codeSystemName").to_s
            if element['code'] != ""
              entry.type = element
            end
          end
          entry.type
        end

        def extract_e2e_severity(parent_element, entry)
          severity_element = parent_element.xpath(@severity_xpath)
          if severity_element
            element = {}
            element['code'] = parent_element.xpath(@severity_xpath+"/@code").to_s
            element['displayName'] = parent_element.xpath(@severity_xpath+"/@displayName").to_s
            element['codeSystem'] = parent_element.xpath(@severity_xpath+"/@codeSystem").to_s
            element['codeSystemName'] = parent_element.xpath(@severity_xpath+"/@codeSystemName").to_s
            if element['code'] != ""
              entry.severity = element
            else
              entry.severity = nil
            end
          end
          entry.severity
        end

        def extract_e2e_reaction(parent_element, entry)
          entry.reaction = {}
          reaction_text = parent_element.xpath(@reaction_xpath+"/cda:text")
          if reaction_text
            entry.reaction["text"] = reaction_text.text()
          end
          reaction_value = parent_element.xpath(@reaction_xpath+"/cda:value")
          if reaction_value
            element = {}
            element["code"] = parent_element.xpath(@reaction_xpath+"/cda:value/@code").to_s
            element["displayName"] = parent_element.xpath(@reaction_xpath+"/cda:value/@displayName").to_s
            element["codeSystem"] = parent_element.xpath(@reaction_xpath+"/cda:value/@codeSystem").to_s
            element["codeSystemName"] = parent_element.xpath(@reaction_xpath+"/cda:value/@codeSystemName").to_s
            if element["code"] != ""
              entry.reaction["value"] = element
            else
              entry.reaction["value"] = nil
            end
          end
          entry.reaction

        end

      end
    end
  end
end