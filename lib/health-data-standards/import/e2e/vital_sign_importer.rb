module HealthDataStandards
  module Import
    module E2E
      class VitalSignImporter < ResultImporter

            # @note The VitalSignImporter class captures the Clinical Observation Section of E2E documents
            #   * For a more thorough description of the vital sign model as used when capturing the vital signs section
            #   * of C32 documents see http://www.mirthcorp.com/community/wiki/pages/viewpage.action?pageId=17105260
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
            # @note The following are XPath locations for E2E information elements captured for the query-gateway results model.
            #   * entry_xpath = "//cda:section[cda:code/@code='CLINOBS']/cda:entry/cda:organizer"
            #   * time_xpath = "./cda:component/cda:observation/cda:effectiveTime"
            #   * description_xpath = "./cda:component/cda:observation/cda:text"
            #   * result_text_xpath = "./cda:component/cda:observation/cda:value"

        def initialize
          super
          @entry_xpath = "//cda:section[cda:code/@code='CLINOBS']/cda:entry/cda:organizer"
          @time_xpath = "./cda:component/cda:observation/cda:effectiveTime"
          @description_xpath = "./cda:component/cda:observation/cda:text"
          @result_text_xpath = "./cda:component/cda:observation/cda:value"
          #@check_for_usable = true               # Pilot tools will set this to false
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
            result_list << result
            #STDERR.puts "RESULT: " + result.inspect
            #if @check_for_usable
            #  result_list << result if result.usable?
            #else
            #  result_list << result
            #end
          end
          result_list
        end

        def create_entry(entry_element, id_map={})
          #print "element: " + entry_element.to_s + "\n"
          result = LabResult.new
          result.interpretation = {}
          extract_dates(entry_element, result)
          extract_result_text(entry_element, result)
          extract_description(entry_element, result)
          result
        end

        private

        def extract_result_text(parent_element, entry)
          result_element = parent_element.at_xpath(@result_text_xpath)
          entry.free_text = result_element.text
        end

        def extract_dates(parent_element, entry)
          time_element = parent_element.at_xpath(@time_xpath)
          if time_element['value']
            entry.time = HL7Helper.timestamp_to_integer(time_element['value'])
          end
        end

        def extract_description(parent_element, entry)
          entry.description = parent_element.at_xpath(@description_xpath).text
        end

      end
    end
  end
end
