module HealthDataStandards
  module Import
    module E2E
      # @note The ConditionImporter class captures the Problems Section of E2E documents
      #   * For a more thorough description of the condition model as used when capturing the problem section of C32 documents see
      #     http://www.mirthcorp.com/community/wiki/plugins/viewsource/viewpagesrc.action?pageId=17105254
      # @note Fields in models/entry.rb
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
      # @note Fields in models/condition.rb
      #   * field :type,          type: String
      #   * field :causeOfDeath,  type: Boolean
      #   * field :priority,      type: Integer
      #   * field :name,          type: String
      #   * field :ordinality,    type: String
      #
      # @note The following XPath locations provide access to E2E information elements
      #   * entry_xpath = "//cda:component/cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.21.1' and cda:code/@code='11450-4']/cda:entry/cda:observation"
      #   * code_xpath = "./cda:entryRelationship/cda:observation/cda:value"
      #   * status_xpath = "./cda:statusCode"
      #   * description_xpath = "./cda:value/cda:originalText[@originalText]"
      #   * provider_xpath = "./cda:author" #"/cda:assignedAuthor"

      class ConditionImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:component/cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.21.1' and cda:code/@code='11450-4']/cda:entry/cda:observation"
          @code_xpath = "./cda:entryRelationship/cda:observation/cda:value"
          @status_xpath = "./cda:statusCode"
          #@priority_xpath = "./cda:priorityCode"
          @description_xpath = "./cda:value/cda:originalText[@originalText]"
          #@description_xpath = "./cda:text/cda:reference[@value]"
          @provider_xpath = "./cda:author" #"/cda:assignedAuthor"
          #@cod_xpath = "./cda:entryRelationship[@typeCode='CAUS']/cda:observation/cda:code[@code='419620001']"
        end
        
        def create_entries(doc, id_map = {})
          @id_map = id_map
          condition_list = []
          entry_elements = doc.xpath(@entry_xpath)
          #print "conditions: " + entry_elements.to_s + "\n"
          
          entry_elements.each do |entry_element|
            condition = Condition.new
            
            extract_codes(entry_element, condition)
            extract_dates(entry_element, condition)
            extract_status(entry_element, condition)
            #extract_priority(entry_element, condition)
            extract_description(entry_element, condition, id_map)
            extract_author_time(entry_element, condition)
            #extract_cause_of_death(entry_element, condition) if @cod_xpath
            #extract_type(entry_element, condition)

            if @provider_xpath
              entry_element.xpath(@provider_xpath).each do |provider_element|
                condition.treating_provider << import_actor(provider_element)
              end
            end

            condition_list << condition
          end
          
          condition_list
        end

        private

        def extract_codes(parent_element, entry)
          code_elements = parent_element.xpath(@code_xpath)
          code_elements.each do |code_element|
            add_code_if_present(code_element, entry)
            entry.description = code_element['displayName']
            entry.type = code_element['type']
          end
        end

        def extract_author_time(parent_element, entry)
          elements = parent_element.xpath(@provider_xpath+"/cda:time/@value")
          entry.time = HL7Helper.timestamp_to_integer(elements.to_s)
        end

        #def extract_cause_of_death(entry_element, condition)
        #  cod = entry_element.at_xpath(@cod_xpath)
        #  condition.cause_of_death = cod.present?
        #end

        #def extract_type(entry_element, condition)
        #  code_element = entry_element.at_xpath('./cda:code')
        #  if code_element
        #    condition.type = case code_element['code']
        #                       when '404684003'  then 'Finding'
        #                       when '418799008'  then 'Symptom'
        #                       when '55607006'   then 'Problem'
        #                       when '409586006'  then 'Complaint'
        #                       when '64572001'   then 'Condition'
        #                       when '282291009'  then 'Diagnosis'
        #                       when '248536006'  then 'Functional limitation'
        #                       else nil
        #                     end
        #  end
        #end


        def extract_status(parent_element, entry)
          status_element = parent_element.xpath(@status_xpath+"/@code").to_s
          #print "status: " + status_element.to_s + "\n"
          entry.status = status_element
        end

      end
    end
  end
end
