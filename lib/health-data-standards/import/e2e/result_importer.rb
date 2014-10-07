#PREFIX_PARTIAL "/ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.3.1818.10.2.16.1' and code/@code='30954-2']/entry/observation"
#PREFIX PREFIX_PARTIAL+"/entryRelationship/organizer/component/observation"
# (*)XPath Suffix appended to PREFIX_PARTIAL rather than full prefix
#OSCAR Table       Field             Notes               Business Term            XPath Suffix

#PatientLabRouting demographic_no    demographic number
#PatientLabRouting lab_no            lab number
#                                    (foreign key)
#Hl7TextInfo       id                primary key         Order Record ID          ./id/@extension (*)
#Hl7TextInfo       obr_date          date test was done  Result Date/Time         ./author/time/@value (*)
#                                                        Specimen Collection Date ./entryRelationship/procedure/effectiveTime/@value
#Hl7TextInfo       requesting_client who requested test? Ordering Provider        ./author/assignedAuthor/assignedPerson/name (*)
#Hl7TextInfo       discipline        type of test done   Order Name               ./text (*)
#Hl7TextInfo       report_status     final, corrected,   Result Status            ./entryRelationship/organizer/statusCode/@code (*)
#                                    preliminary
#measurements      dataField         freetext result     Result Value             ./value
#measurements      comments          freetext comments   Result Notes             ./entryRelationship/observation/value
#
#measurementsExt   abnormal          normal/abnormal     Interpretation Code      ./interpretationCode
#measurementsExt   identifier        LOINC               Result Observation Code  ./code/@code
#measurementsExt   name              freetext test name  Result Observation Code  ./code/@displayName
#                                                        Result Name              ./text
#measurementsExt   labname           lab name            Represented Organization ./performer/assignedEntity/representedOrganization/name
#                                                        > Name
#measurementsExt   accession         accession number    Result Observation       ./id/@extension
#                                                        Record ID
#measurementsExt   datetime          time performed      Result Organizer Status  ./effectiveTime/@value
#                                                        Resulting Organization   ./performer/time/@value
#                                                        > Performed Date/Time
#measurementsExt   olis_status       final, corrected,   Result Status            ./statusCode/@code
#                                    preliminary
#measurementsExt   unit              measurement unit    Result Value             ./value/@unit
#measurementsExt   range             freetext            Reference Range Text     ./referenceRange/observationRange/text
#                                                        Reference Range Value    ./referenceRange/observationRange/value
#measurementsExt   minimum           numeric freetext    Reference Range Text     ./referenceRange/observationRange/text
#                                                        Reference Range Value    ./referenceRange/observationRange/value/low
#measurementsExt   maximum           numeric freetext    Reference Range Text     ./referenceRange/observationRange/text
#                                                        Reference Range Value    ./referenceRange/observationRange/value/high
#measurementsExt   other_id          defines battery     Result Organizer         ./entryRelationship/organizer/id/@extension (*)
#                                    groupings           Record ID


module HealthDataStandards
  module Import
    module E2E

      # @note The ResultImporter class captures the Laboratory Results Section of E2E documents
      #   * For a more thorough description of the laboratory result model as used when capturing the results section of C32 documents see
      #     http://www.mirthcorp.com/community/wiki/plugins/viewsource/viewpagesrc.action?pageId=17105264
      #
      # @note class Entry
      #   * field :description, type: String
      #   * field :specifics, type: String
      #   * field :time, type: Integer
      #   * field :start_time, type: Integer
      #   * field :end_time, type: Integer
      #   * field :status, type: String
      #   * field :codes, type: Hash, default: {}
      #   * field :value, type: Hash, default: {}
      #   * field :free_text, type: String
      #   * field :mood_code, type: String, default: "EVN"
      #
      # @note class LabResult < Entry
      #   * field :referenceRange, type: String
      #   * field :interpretation, type: Hash
      #
      # @note The following are XPath locations for E2E information elements captured by the query-gateway results model.
      #   * entry_xpath = "/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/"+
      #      "cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.16.1' and cda:code/@code='30954-2']/"+
      #      "cda:entry/cda:observation/cda:entryRelationship/cda:organizer/cda:component/cda:observation"
      #   * code_xpath = "./cda:code"
      #   * referencerange_xpath = "./cda:referenceRange"
      #   * interpretation_xpath = "./cda:interpretationCode"
      #   * description_xpath = "./cda:text/text()"
      #   * status_xpath = "./cda:statusCode/@code"
      #
      class ResultImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.16.1' and cda:code/@code='30954-2']/cda:entry/cda:observation/cda:entryRelationship/cda:organizer/cda:component/cda:observation"
          @code_xpath = "./cda:code"
          @referencerange_xpath = "./cda:referenceRange"
          @interpretation_xpath = "./cda:interpretationCode"
          @description_xpath = "./cda:text/text()"
          @status_xpath = "./cda:statusCode/@code"
          #@check_for_usable = true              # Pilot tools will set this to false
        end
    
        # Traverses the E2E document passed in using XPath and creates an Array of Entry
        # objects based on what it finds                          
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        #        measure definition
        # @return [Array] will be a list of Entry objects
        def create_entries(doc,id_map = {})
          result_list = []
          entry_elements = doc.xpath(@entry_xpath)
          entry_elements.each do |entry_element|
            result = create_entry(entry_element, id_map)
            #if @check_for_usable
            #  result_list << result if result.usable?
            #else
              result_list << result
            #end
          end
          result_list
        end
        
        def create_entry(entry_element, id_map={})
          result = LabResult.new
          result.interpretation = {}
          extract_codes(entry_element, result)
          extract_dates(entry_element, result)
          extract_e2e_value(entry_element, result)
          extract_interpretation(entry_element, result)
          extract_description(entry_element, result)
          extract_status(entry_element, result)
          extract_reference_range(entry_element, result)
          result
        end
    
        private

        #TODO after debugging complete use extract_value method in section_importer.rb
        def extract_e2e_value(parent_element, entry)
          value_element = parent_element.at_xpath('cda:value')
          if value_element
            #TODO find out why type isn't captured consistently by hds and query-gateway; maybe due to different nokogiri versions
            type = value_element['type'] #works for hds testing
            type ||= value_element['xsi:type'] #works for query-gateway testing (different nokogiri versions?)
            value = value_element['value']
            unit = value_element['unit']
            value ||= value_element.text
            if value
              if type == 'PQ'
                entry.set_value(value.strip, unit)
              elsif type == 'ST'
                entry.free_text = value
              else
                #TODO This next assignment of value is only here to preserve backward compatabilty
                entry.set_value(value.strip, unit)
              end
            end

          end
        end

        def extract_reference_range(parent_element, result)
          elements = parent_element.xpath(@referencerange_xpath+"/cda:observationRange/cda:text/text()")
          if not elements.empty?
            result.referenceRange = ""
            elements.each do |element|
              result.referenceRange = result.referenceRange + element.to_s
              if elements.size > 1
                result.referenceRange = result.referenceRange + "; "
              end
            end
          else
            result.referenceRange = "unspecified"
          end
        end

        def extract_interpretation(parent_element, result)
          interpretation_element = parent_element.at_xpath(@interpretation_xpath)
          if interpretation_element
            code = interpretation_element['code']
            code_system = CodeSystemHelper.code_system_for(interpretation_element['codeSystem'])
            result.interpretation = {'code' => code, 'codeSystem' => code_system}
          end
        end

        def extract_codes(parent_element, entry)
          code_elements = parent_element.xpath(@code_xpath)

          code_elements.each do |code_element|
            add_code_if_present(code_element, entry)
          end
        end

        def add_code_if_present(code_element, entry)
          if code_element['codeSystemName'] && code_element['code']
            entry.add_code(code_element['code'], code_element['codeSystemName'])
          end
        end

        def extract_description(parent_element, entry)
          entry.description = parent_element.xpath(@description_xpath)
        end

        def extract_status(parent_element, entry)
          status_element = parent_element.xpath(@status_xpath)
          entry.status_code = {value: status_element.to_s}
        end

      end
    end
  end
end