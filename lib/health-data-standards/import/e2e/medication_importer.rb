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
          @timing_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:effectiveTime/cda:frequency"
          @freetext_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.3.1818.10.4.35']/cda:observation/cda:text/text()"
          @dose_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:doseQuantity"
          @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:code"
          @description_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:name/text()"

          @route_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:routeCode"
          @form_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:administrationUnitCode"
          @status_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:statusCode"
          #type of medication is not captured by e2e
          #@type_of_med_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.8.1']/cda:code"
          #can't match these with e2e element
          #@indication_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.28']/cda:code"
          #@vehicle_xpath = "cda:participant/cda:participantRole[cda:code/@code='412307009' and cda:code/@codeSystem='2.16.840.1.113883.6.96']/cda:playingEntity/cda:code"
          @fill_number_xpath = "./cda:entryRelationship[@typeCode='COMP']/cda:sequenceNumber/@value"
          @strength_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:strength"

          @check_for_usable = true               # Pilot tools will set this to false
        end
        
        def create_entry(entry_element, id_map={})
          medication = Medication.new

          medication.administrationTiming={}
          medication.freeTextSig=""
          medication.dose={}
          medication.typeOfMedication={}
          medication.statusOfMedication={}
          medication.route={}
          medication.site={}
          medication.doseRestriction={}
          medication.fulfillmentInstructions=""
          medication.indication={}
          medication.productForm={}
          medication.vehicle={}
          medication.reaction={}
          medication.deliveryMethod={}
          medication.patientInstructions=""
          medication.doseIndicator=""
          #medication.cumulativeMedicationDuration={}

          extract_codes(entry_element, medication)
          #extract_dates(entry_element, medication)
          extract_description(entry_element, medication)
          
          #if medication.description.present?
          #  medication.free_text = medication.description
          #end
          extract_free_text(entry_element, medication)

          extract_administration_timing(entry_element, medication)

          #medication.route = extract_code(entry_element, "./cda:routeCode")
          #medication.dose = extract_scalar2(entry_element, "./cda:strength/cda:center")
          #medication.site = extract_code(entry_element, "./cda:approachSiteCode", 'SNOMED-CT')
          extract_route(entry_element, medication)
          extract_form(entry_element, medication)
          extract_dose_restriction(entry_element, medication)
          extract_dose(entry_element, medication)

          #medication.product_form = extract_code(entry_element, "./cda:administrationUnitCode", 'NCI Thesaurus')
          #medication.delivery_method = extract_code(entry_element, "./cda:code", 'SNOMED-CT')
          #medication.type_of_medication = extract_code(entry_element, @type_of_med_xpath, 'SNOMED-CT') if @type_of_med_xpath
          #medication.indication = extract_code(entry_element, @indication_xpath, 'SNOMED-CT')
          #medication.vehicle = extract_code(entry_element, @vehicle_xpath, 'SNOMED-CT')

          extract_order_information(entry_element, medication)
          extract_dates(entry_element, medication)
          extract_author_time(entry_element, medication)
          extract_fulfillment_history(entry_element, medication)
          medication
        end

        private

        def extract_description(parent_element, entry)
          code_elements = parent_element.xpath(@description_xpath)
          code_elements.each do |code_element|
            entry.description = code_element
          end
        end

        # Find date in Medication Prescription Event. Commented out because there should be an
        # orderinformation object created to hold the prescription dates.

        def extract_dates(parent_element, entry, element_name="effectiveTime")
          #print "XML Node: " + parent_element.to_s + "\n"
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
          #print "Codes: " + entry.codes_to_s + "\n"
          #print "Time: " + entry.time.to_s + "\n"
          #print "Start Time: " + entry.start_time.to_s + "\n"
          #print "End Time: " + entry.end_time.to_s + "\n"
        end

        def extract_author_time(parent_element, entry, element_name="author")
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}")
            entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:time")['value'])
          end
        end


        def extract_fulfillment_history(parent_element, medication)
          fhs = parent_element.xpath("./cda:entryRelationship/cda:supply[@moodCode='EVN']")
          if fhs
            fhs.each do |fh_element|
              fulfillment_history = FulfillmentHistory.new
              fulfillment_history.prescription_number = fh_element.at_xpath('./cda:id').try(:[], 'root')
              actor_element = fh_element.at_xpath('./cda:performer')
              if actor_element
                fulfillment_history.provider = import_actor(actor_element)
              end
              hl7_timestamp = fh_element.at_xpath('./cda:effectiveTime').try(:[], 'value')
              fulfillment_history.dispense_date = HL7Helper.timestamp_to_integer(hl7_timestamp) if hl7_timestamp
              fulfillment_history.quantity_dispensed = extract_scalar(fh_element, "./cda:quantity")
              #fill_number = fh_element.at_xpath(@fill_number_xpath).try(:text)
              #fulfillment_history.fill_number = fill_number.to_i if fill_number
              medication.fulfillmentHistory << fulfillment_history
            end
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

        #def extract_order_information(parent_element, medication)
        #  order_elements = parent_element.xpath("./cda:entryRelationship[@typeCode='REFR']/cda:supply[@moodCode='INT']")
        #  if order_elements
        #    order_elements.each do |order_element|
        #      order_information = OrderInformation.new

        #      order_information.order_number = order_element.at_xpath('./cda:id').try(:[], 'root')
        #      order_information.fills = order_element.at_xpath('./cda:repeatNumber').try(:[], 'value').try(:to_i)
        #      order_information.quantity_ordered = extract_scalar(order_element, "./cda:quantity")

        #      medication.orderInformation << order_information
        #    end
        #  end
        #end

        #def extract_administration_timing(parent_element, medication)
        #  administration_timing_element = parent_element.at_xpath("./cda:effectiveTime[2]")
        #  if administration_timing_element
        #    at = {}
        #    if administration_timing_element['institutionSpecified']
        #      at['institutionSpecified'] = administration_timing_element['institutionSpecified'].to_boolean
        #    end
        #    at['period'] = extract_scalar(administration_timing_element, "./cda:period")
        #    if at.present?
        #      medication.administration_timing = at
        #    end
        #  end
        #end

        def extract_administration_timing(parent_element, medication)
          ate = parent_element.xpath(@timing_xpath)
          #print "administration_timing: " + ate.to_s + "\n"
          if ate
            at = {}
            at['numerator'] = extract_scalar(ate, "./cda:numerator")
            at['denominator'] = extract_scalar(ate, "./cda:denominator")
            medication.administration_timing = at
          end
        end

        def extract_free_text(parent_element, entry)
          code_elements = parent_element.xpath(@freetext_xpath)
          #print "free text: " + code_elements.to_s + "\n"
          code_elements.each do |code_element|
            entry.free_text = code_element
          end
        end

        def extract_dose(parent_element, entry)
          code_elements = parent_element.xpath(@dose_xpath)
          print "XML Node: " + code_elements.to_s + "\n"
          code_elements.each do |code_element|
            drs = code_element
            #print "drs: " + drs.to_s + "\n"
            if drs
              dr = {}
              dr['low'] = drs['low']
              dr['high'] = drs['high']
              entry.dose = dr
              print "dose: " + entry.dose.to_s + "\n"
            end
          end
        end

        def extract_dose_restriction(parent_element, medication)
          dre = parent_element.at_xpath("./cda:maxDoseQuantity")
          if dre
            dr = {}
            dr['numerator'] = extract_scalar(dre, "./cda:numerator")
            dr['denominator'] = extract_scalar(dre, "./cda:denominator")
            medication.dose_restriction = dr
          end
        end

        def extract_description(parent_element, entry)
          code_elements = parent_element.xpath(@description_xpath)
          code_elements.each do |code_element|
            entry.description = code_element
          end
        end

      def extract_status(parent_element, entry)
        code_elements = parent_element.xpath(@status_xpath)
        code_elements.each do |code_element|
          entry.status = code_element
        end
      end


      def extract_route(parent_element, entry)
          code_elements = parent_element.xpath(@route_xpath)
          #print "Route XML Node: " + code_elements.to_s + "\n"
          code_elements.each do |code_element|
            route = {}
            route['code'] = code_element['code']
            route['codeSystem'] = code_element['codeSystem']
            route['codeSystemName'] = code_element['codeSystemName']
            route['displayName'] = code_element['displayName']
            entry.route = route
          end
        end

        def extract_form(parent_element, entry)
          code_elements = parent_element.xpath(@form_xpath)
          #print "Form XML Node: " + code_elements.to_s + "\n"
          code_elements.each do |code_element|
            content = {}
            content['code'] = code_element['code']
            content['codeSystem'] = code_element['codeSystem']
            content['displayName'] = code_element['displayName']
            entry.productForm = content
          end
          #print "code: " + entry.productForm.to_s + "\n"
        end



      end
    end
  end
end