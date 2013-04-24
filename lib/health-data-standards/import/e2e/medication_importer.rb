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
          # start of medication section
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.19.1' and cda:code/@code='10160-6']/cda:entry/cda:substanceAdministration"

          # location of base Entry class fields
          @description_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:name/text()"
          @entrystatus_xpath = "./cda:statusCode"            # not used
          @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:code"
          # using cda:strength to populate Entry.value
          @strength_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:strength"

          # location of Medication class fields
          # administrationTiming [frequency of drug - could be specific time, interval (every 6 hours), duration (infuse over 30 minutes) but e2e uses frequency only]
          @timing_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:effectiveTime/cda:frequency"
          # freeTextSig (Instructions to patient)
          @freetext_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.3.1818.10.4.35']/cda:observation/cda:text/text()"
          # doseQuantity
          @dose_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:doseQuantity"
          # statusOfMedication (active, discharged, chronic, acute)
          @status_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:statusCode"
          # route (by mouth, intravenously, topically, etc.)
          @route_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:routeCode"
          # productForm (tablet, capsule, liquid, ointment)
          @form_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:administrationUnitCode"

          # location of embedded OrderInformation class fields
          # orderNumber (order identifier from perspective of ordering clinician)
          @orderno_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:id"
          # orderExpirationDateTime (Date when order is no longer valid)
          @expiredate_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:effectiveTime/cda:high"
          # orderDateTime (Date when order provider wrote the order/prescription)
          @orderdate_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:author/cda:time"

          # Entry fields not captured by e2e:
          #  specifics
          #  free_text (instructions from the ordering provider to patient)

          # Medication fields not captured by e2e:
          #  typeOfMedication (e.g., prescription, over-counter, etc.)
          #  site (anatomic site where medication is administered)
          #  doseRestriction (maximum dose limit)
          #  fulfillmentInstructions (instructions to the dispensing pharmacist)
          #  indication (medical condition or problem addressed by the ordered product)
          #  vehicle (substance in which the active ingredients are dispersed, e.g., saline solution)
          #  reaction (note of intended or unintended effects, e.g., rash, nausea)
          #  deliveryMethod (how product is administered/consumed)
          #  patientInstructions (instructions not part of free text sig like "keep in the refrigerator")
          #  doseIndicator (when action is to be taken, example "if blood sugar is above 250 mg/dl")
          #
          # OrderInformation fields not captured by e2e:
          #  fills (number of times ordering provider has authorized pharmacy to dispense this medication)
          #  quantityOrdered (number of dosage units or volume of liquid substance)

          @check_for_usable = true               # Pilot tools will set this to false
        end
        
        def create_entry(entry_element, id_map={})
          medication = Medication.new

          medication.administrationTiming={}
          medication.freeTextSig=""
          medication.dose={}
          #medication.typeOfMedication={}
          medication.statusOfMedication={}
          medication.route={}
          #medication.site={}
          #medication.doseRestriction={}
          #medication.fulfillmentInstructions=""
          #medication.indication={}
          medication.productForm={}
          #medication.vehicle={}
          #medication.reaction={}
          #medication.deliveryMethod={}
          #medication.patientInstructions=""
          #medication.doseIndicator=""
          # the following isn't in the IT4 model
          #medication.cumulativeMedicationDuration={}

          extract_description(entry_element, medication)
          extract_codes(entry_element, medication)
          extract_entry_value(entry_element, medication)
          extract_dates(entry_element, medication)

          extract_administration_timing(entry_element, medication)
          extract_freetextsig(entry_element, medication)
          extract_dose(entry_element, medication)
          extract_status(entry_element, medication)
          extract_route(entry_element, medication)
          extract_form(entry_element, medication)

          #extract_order_information(entry_element, medication)
          extract_author_time(entry_element, medication)
          #extract_fulfillment_history(entry_element, medication)
          medication
        end

        private

        def extract_description(parent_element, entry)
          code_elements = parent_element.xpath(@description_xpath)
          code_elements.each do |code_element|
            entry.description = code_element
          end
        end

        def extract_entry_value(parent_element, entry)
          value = {}
          value['value'] = parent_element.xpath(@strength_xpath+"/cda:center/@value").to_s
          value['unit'] = parent_element.xpath(@strength_xpath+"/cda:center/@unit").to_s
          entry.value = value
        end

        # Find date in Medication Prescription Event.
        def extract_dates(parent_element, entry, element_name="effectiveTime")
          #print "XML Node: " + parent_element.to_s + "\n"
          #if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}")
          #  entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}")['value'])
          #end
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:low")
            entry.start_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:low")['value'])
          end
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:high")
            entry.end_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:high")['value'])
          end
          #if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:center")
          #  entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:center")['value'])
          #end
          #print "Codes: " + entry.codes_to_s + "\n"
          #print "Time: " + entry.time.to_s + "\n"
          #print "Start Time: " + entry.start_time.to_s + "\n"
          #print "End Time: " + entry.end_time.to_s + "\n"
        end

        # this method only handles drug administration timing expressed as a frequency
        # (does not handle specific time, interval or duration specifications)
        def extract_administration_timing(parent_element, medication)
          ate = parent_element.xpath(@timing_xpath)
          #print "administration_timing: " + ate.to_s + "\n"
          if ate
            at = {}
            at['numerator'] = extract_scalar(ate, "./cda:numerator")
            at['denominator'] = extract_scalar(ate, "./cda:denominator")
            medication.administration_timing['frequency'] = at
          end
        end

        def extract_freetextsig(parent_element, entry)
          entry.freeTextSig = parent_element.xpath(@freetext_xpath).to_s
        end

        def extract_dose(parent_element, entry)
          dose = {}
          dose['low'] = parent_element.xpath(@dose_xpath+'/cda:low/@value').to_s
          dose['high'] = parent_element.xpath(@dose_xpath+"/cda:high/@value").to_s
          entry.dose = dose
        end

        def extract_status(parent_element, entry)
          status_element = parent_element.xpath(@status_xpath+"/@code").to_s
          #print "status: " + status_element.to_s + "\n"
          entry.statusOfMedication = status_element
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

        #def extract_order_information(parent_element, medication)
        #  order_elements = parent_element.xpath("./cda:entryRelationship[@typeCode='REFR']/cda:supply[@moodCode='INT']")
        #  if order_elements
        #    order_elements.each do |order_element|
        #      order_information = OrderInformation.new
        #      actor_element = order_element.at_xpath('./cda:author')
        #      if actor_element
        #        order_information.provider = ProviderImporter.instance.extract_provider(actor_element, "assignedAuthor")
        #      end
        #      order_information.order_number = order_element.at_xpath('./cda:id').try(:[], 'root')
        #      order_information.fills = order_element.at_xpath('./cda:repeatNumber').try(:[], 'value').try(:to_i)
        #      order_information.quantity_ordered = extract_scalar(order_element, "./cda:quantity")
        #
        #      medication.orderInformation << order_information
        #    end
        #  end
        #end

        def extract_author_time(parent_element, entry, element_name="author")
          if parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}")
            entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:entryRelationship/cda:substanceAdministration/cda:#{element_name}/cda:time")['value'])
          end
        end


        #def extract_fulfillment_history(parent_element, medication)
        #  fhs = parent_element.xpath("./cda:entryRelationship/cda:supply[@moodCode='EVN']")
        #  if fhs
        #    fhs.each do |fh_element|
        #      fulfillment_history = FulfillmentHistory.new
        #      fulfillment_history.prescription_number = fh_element.at_xpath('./cda:id').try(:[], 'root')
        #      actor_element = fh_element.at_xpath('./cda:performer')
        #      if actor_element
        #        fulfillment_history.provider = import_actor(actor_element)
        #      end
        #      hl7_timestamp = fh_element.at_xpath('./cda:effectiveTime').try(:[], 'value')
        #      fulfillment_history.dispense_date = HL7Helper.timestamp_to_integer(hl7_timestamp) if hl7_timestamp
        #      fulfillment_history.quantity_dispensed = extract_scalar(fh_element, "./cda:quantity")
        #      #fill_number = fh_element.at_xpath(@fill_number_xpath).try(:text)
        #      #fulfillment_history.fill_number = fill_number.to_i if fill_number
        #      medication.fulfillmentHistory << fulfillment_history
        #    end
        #  end
        #end
      end
    end
  end
end