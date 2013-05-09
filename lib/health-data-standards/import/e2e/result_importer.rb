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
      #   * entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.16.1' and cda:code/@code='11502-2']/cda:entry/cda:observation/cda:entryRelationship/cda:organizer/cda:component/cda:observation"
      #   * code_xpath = "./cda:code"
      #   * interpretation_xpath = "./cda:interpretationCode"
      #   * description_xpath = "./cda:text/text()"
      #   * status_xpath = "./cda:statusCode/@code"
      #
      class ResultImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.16.1' and cda:code/@code='11502-2']/cda:entry/cda:observation/cda:entryRelationship/cda:organizer/cda:component/cda:observation"
          @code_xpath = "./cda:code"
          @referencerange_xpath = "./cda:referenceRange"
          @interpretation_xpath = "./cda:interpretationCode"
          @description_xpath = "./cda:text/text()"
          @status_xpath = "./cda:statusCode/@code"
          @check_for_usable = true               # Pilot tools will set this to false
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
            #print "result: " + entry_element.to_s + "\n"
            result = create_entry(entry_element, id_map)
            if @check_for_usable
              result_list << result if result.usable?
            else
              result_list << result
            end
          end
          result_list
        end
        
        def create_entry(entry_element, id_map={})
          #print "element: " + entry_element.to_s + "\n"
          result = LabResult.new
          result.interpretation = {}
          extract_codes(entry_element, result)
          extract_status(entry_element, result)
          extract_dates(entry_element, result)
          extract_value(entry_element, result)
          extract_description(entry_element, result)
          extract_referencerange(entry_element, result)
          extract_interpretation(entry_element, result)
          result
        end
    
        private

        def extract_referencerange(parent_element, result)
          element = parent_element.xpath(@referencerange_xpath+"/cda:observationRange/cda:text/text()")
          result.referenceRange = element.to_s if not element.empty?

        end

        def extract_interpretation(parent_element, result)
          interpretation_element = parent_element.xpath(@interpretation_xpath+"/@code")
          if interpretation_element
            code = interpretation_element.to_s
            result.interpretation = {'code' => code, 'codeSystem' => nil}
          end
        end

        def extract_codes(parent_element, entry)
          code_elements = parent_element.xpath(@code_xpath)

          code_elements.each do |code_element|
            #print "codes: " + code_element.to_s + "\n"
            add_code_if_present(code_element, entry)
          end
        end

        def add_code_if_present(code_element, entry)
          if code_element['codeSystemName'] && code_element['code']
            entry.add_code(code_element['code'], code_element['codeSystemName'])
            #print "code: " + entry.codes.to_s + "\n"
          end
        end

        def extract_description(parent_element, entry)
          entry.description = parent_element.xpath(@description_xpath)
        end

        def extract_status(parent_element, entry)
          status_element = parent_element.at_xpath(@status_xpath)
          if status_element
            entry.status =  status_element
          end
        end
      end
    end
  end
end
