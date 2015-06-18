# XPath prefix /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.3.1818.10.2.21.1' and code/@code='11450-4']/entry/observation
#
#OSCAR Table    Field           Notes                   Business Term            XPath(suffix)
#-----------    -----           -----                   -------------            -------------
#dxresearch     dxresearch_no   Primary Key             Record ID                ./id/@extension
#dxresearch     demographic_no  Identify if problem
#                               record is part of
#                               this patient
#dxresearch     start_date      Specified by user       Onset Date/Date Resolved ./effectiveTime/low/@value
#                                                       Diagnosis Date           ./entryRelationship/observation/effectiveTime/@value
#dxresearch     update_date     Time last edited        Authored Date/Time       ./author/time/@value
#dxresearch     status          Active, Completed       Problem Status           ./statusCode/@code
#                               or Deleted
#dxresearch     dxresearch_code ICD9 or ichppccode?     Diagnosis Billing Code   ./entryRelationship/observation/value/@code
#                               Value
#dxresearch     coding_system   ICD9 or ichppccode
#
#icd9           description     Description             Diagnosis Text           ./text
#                                                       Diagnosis Billing Code   ./entryRelationship/observation/value/@displayName


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
      #   * entry_xpath = "/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.21.1' and cda:code/@code='11450-4']/cda:entry/cda:observation"
      #   * code_xpath = "./cda:entryRelationship/cda:observation[cda:code/@code='BILLINGCODE']/cda:value"
      #   * status_xpath = "./cda:statusCode"
      #   * description_xpath = "./cda:entryRelationship/cda:observation[cda:code/@code='BILLINGCODE']/cda:value" #./cda:value/cda:originalText[@originalText]
      #   * provider_xpath = "./cda:author/cda:assignedAuthor"

      class ConditionImporter < SectionImporter

        def initialize
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.21.1' and cda:code/@code='11450-4']/cda:entry/cda:observation"
          #@entry_xpath = "/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.21.1' and cda:code/@code='11450-4']/cda:entry/cda:observation"
          @code_xpath = "./cda:entryRelationship/cda:observation[cda:code/@code='BILLINGCODE' or cda:code/@code='ICD9CODE']/cda:value"
          @status_xpath = "./cda:statusCode"
          #@priority_xpath = "./cda:priorityCode"
          @description_xpath = "./cda:entryRelationship/cda:observation[cda:code/@code='BILLINGCODE' or cda:code/@code='ICD9CODE']/cda:value"
          @description_secondary_xpath = "./cda:text/text()"
          @provider_xpath = "./cda:author/cda:assignedAuthor"
          #@cod_xpath = "./cda:entryRelationship[@typeCode='CAUS']/cda:observation/cda:code[@code='419620001']"
        end
        
        def create_entries(doc, id_map = {})
          @id_map = id_map
          condition_list = []
          entry_elements = doc.xpath(@entry_xpath)

          entry_elements.each do |entry_element|
            condition = Condition.new
            
            extract_codes(entry_element, condition)
            extract_dates(entry_element, condition)
            extract_status(entry_element, condition)
            #extract_priority(entry_element, condition)
            #extract_description(entry_element, condition, id_map)
            extract_e2e_description(entry_element, condition)
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
            entry.type ||= code_element['xsi:type']
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

        def extract_e2e_description(parent_element, entry)
          if parent_element.at_xpath(@description_xpath+'/@displayName') then
            entry.description = parent_element.xpath(@description_xpath+'/@displayName')
          else
            entry.description = parent_element.xpath(@description_secondary_xpath).to_s
          end
        end

        def extract_status(parent_element, entry)
          status_element = parent_element.xpath(@status_xpath+"/@code").to_s
          #print "status: " + status_element.to_s + "\n"
          entry.status = status_element
        end

      end
    end
  end
end
