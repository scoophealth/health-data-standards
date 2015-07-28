module HealthDataStandards
  module Import
    module E2E

      #Common prefix for XPath expressions:
      #/ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.3.1818.10.2.19.1' and code/@code='10160-0']/entry/substanceAdministration
      #OSCAR Field          Notes                       Business Term         Field                 XPath
      #drugid               Unique ID in database       Record ID             id
      #provider_no          Doctor who prescribed/recordPrescribing Provider  assignedPerson > name ./entryRelationship/substanceAdministration/author/assignedAuthor/assignedPerson/name
      #demographic_no       Identify if med record is pa
      #rx_date              Prescription start          Start/Stop Date       effectiveTime > low   ./entryRelationship/substanceAdministration/effectiveTime/low/@value
      #end_date             Prescription end            Start/Stop Date       effectiveTime > high  ./entryRelationship/substanceAdministration/effectiveTime/high/@value
      #written_date         Date written                Authored Date/Time    time                  ./entryRelationship/substanceAdministration/author/time/@value
      #BN                   Long name of drug (name + stDrug Description      manufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:desc
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:desc
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:desc
      #takemin              Minimum to take per administDose Instructions     doseQuantity low      ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/doseQuantity/low/@value
      #                                                 Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #takemax              Maximum to take per administDose Instructions     doseQuantity high     ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/doseQuantity/high/@value
      #                                                 Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #freqcode             Coded frequency (TID)to fracFrequency             numerator value       ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/frequency/numerator/@value
      #                                                 Frequency             denominator value     ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/frequency/denominator/@value
      #                                                 Frequency             denominator unit      ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/frequency/denominator/@unit
      #                                                 Period                low value             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/period/low/@value
      #                                                 Period                low unit              ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/period/low/@unit
      #                                                 Period                high value            ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/period/high/@value
      #                                                 Period                high unit             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/period/high/@unit
      #                                                 Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #duration             Length of time              Duration              effectiveTime > width ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/width/@value
      #                                                 Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #durunit              Coded unit of time (D)      Duration              effectiveTime > width ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/effectiveTime/width/@unit
      #                                                 Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #prn                  Pro re nata - use as needed Order Indicators      observation > value va./entryRelationship/substanceAdministration/entryRelationship/observation/value/@value
      #special_instruction  Special freetext instructionInstructions to Patienobservation > text    ./entryRelationship/substanceAdministration/entryRelationship/observation[participant/participantRole/@classCode='PAT']/text/text()
      #archived             Was it "archived" or deleted
      #GN                   Generic Name of drug        Drug Name             manufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/name
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/name
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/name
      #                                                 Ingredient Name       manufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:ingredient/e2e:name
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:ingredient/e2e:name
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:ingredient/e2e:name
      #                                                 Drug Code             manufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/code/@displayName
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/code/@displayName
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/code/@displayName
      #ATC                  Anatomical Therapeutic ChemiDrug Code             manufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/code/@code
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/code/@code
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/code/@code
      #regional_identifier  DIN Number                  Drug Code             manufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/code/@code
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/code/@code
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/code/@code
      #unit                 Part of dose - unit of measuDrug Ingredient QuantimanufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:quantity/@unit
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:quantity/@unit
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:quantity/@unit
      #method               How to administer           Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #route                Route of entry into patient Route                 routeCode code        ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/routeCode
      #                                                 Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #drug_form            Form of the drug            Form                  administrationUnitCode./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/administrationUnitCode
      #                                                 Duration              text                  ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/text
      #dosage               How much of the drug        Drug Ingredient QuantimanufacturedLabeledDru./consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:quantity/@value
      #                                                                                             ./entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:quantity/@value
      #                                                                                             ./entryRelationship/substanceAdministration/entryRelationship/substanceAdministration/consumable/manufacturedProduct/manufacturedLabeledDrug/e2e:ingredient/e2e:quantity/@value
      #long_term            Is a drug still "active" forRecord Status         statusCode            ./statusCode/@code
      #lastUpdateDate       Most recent update to medicaLast Review Date      effectiveTime value   ./entryRelationship/observation/effectiveTime/@value




      # TODO: Coded Product Name, Free Text Product Name, Coded Brand Name and Free Text Brand name need to be pulled out separatelty
      #       This would mean overriding extract_codes
      # TODO: Patient Instructions needs to be implemented. Will likely be a reference to the narrative section
      # TODO: Couldn't find an example medication reaction. Isn't clear to me how it should be implemented from the specs, so
      #       reaction is not implemented.
      # TODO: Couldn't find an example dose indicator. Isn't clear to me how it should be implemented from the specs, so
      #       dose indicator is not implemented.
      # TODO: Fill Status is not implemented. Couldn't figure out which entryRelationship it should be nested in

      # @note The MedicationImporter class captures the Medications Section of E2E documents
      #   * For a more thorough description of the medication model as used when capturing the medication section of C32 documents see
      #     http://www.mirthcorp.com/community/wiki/plugins/viewsource/viewpagesrc.action?pageId=17105258
      #
      # @note The following are XPath locations for E2E information elements captured by the query-gateway medication model.
      #
      # @note Start of medication section
      #   * entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.19.1' and cda:code/@code='10160-0']/cda:entry/cda:substanceAdministration"
      #
      # @note Location of base Entry class fields
      #   * description_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:name/text()"
      #   * entrystatus_xpath = "./cda:statusCode"            # not used at the moment
      #   * code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:code"
      #   * strength_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:strength"
      #     * using cda:strength to populate Entry.value
      #
      # @note Location of Medication class fields
      #   * administrationTiming [frequency of drug - could be specific time, interval (e.g., every 6 hours), duration (e.g., infuse over 30 minutes) but e2e uses frequency only]
      #     * timing_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:effectiveTime/cda:frequency"
      #   * freeTextSig (Instructions to patient)
      #     * freetext_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.3.1818.10.4.35']/cda:observation/cda:text/text()"
      #   * doseQuantity
      #     * dose_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:doseQuantity"
      #   * statusOfMedication (active, discharged, chronic, acute)
      #     * status_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:statusCode"
      #   * route (by mouth, intravenously, topically, etc.)
      #     * route_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:routeCode"
      #   * productForm (tablet, capsule, liquid, ointment)
      #     * form_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:administrationUnitCode"
      #
      # @note Location of embedded OrderInformation class fields
      #   * orderNumber (order identifier from perspective of ordering clinician)
      #     * orderno_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:id"
      #   * orderExpirationDateTime (Date when order is no longer valid)
      #     * expiredate_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:effectiveTime/cda:high"
      #   * orderDateTime (Date when order provider wrote the order/prescription)
      #     * orderdate_xpath = "./cda:entryRelationship/cda:substanceAdministration/cda:author/cda:time"
      #
      # @note Entry fields not captured by e2e:
      #   * specifics
      #   * free_text (instructions from the ordering provider to patient)
      #
      # @note Medication fields not captured by e2e:
      #   * typeOfMedication (e.g., prescription, over-counter, etc.)
      #   * site (anatomic site where medication is administered)
      #   * doseRestriction (maximum dose limit)
      #   * fulfillmentInstructions (instructions to the dispensing pharmacist)
      #   * indication (medical condition or problem addressed by the ordered product)
      #   * vehicle (substance in which the active ingredients are dispersed, e.g., saline solution)
      #   * reaction (note of intended or unintended effects, e.g., rash, nausea)
      #   * deliveryMethod (how product is administered/consumed)
      #   * patientInstructions (instructions not part of free text sig like "keep in the refrigerator")
      #   * doseIndicator (when action is to be taken, example "if blood sugar is above 250 mg/dl")
      #
      # @note OrderInformation fields not captured by e2e:
      #   * fills (number of times ordering provider has authorized pharmacy to dispense this medication)
      #   * quantityOrdered (number of dosage units or volume of liquid substance)
      #
      class MedicationImporter < SectionImporter

        def initialize
          # start of medication section
          @entry_xpath = "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.1818.10.2.19.1' and cda:code/@code='10160-0']/cda:entry/cda:substanceAdministration"

          # location of base Entry class fields
          @description_xpath = './cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug'#/e2e:desc/text()'
          @entrystatus_xpath = './cda:statusCode' # not used
          @code_xpath = './cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:code'
          # using cda:strength to populate Entry.value
          #@strength_xpath = './cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/cda:strength'
          @strength_xpath = './cda:consumable/cda:manufacturedProduct/cda:manufacturedLabeledDrug/e2e:ingredient/e2e:quantity'

          # location of Medication class fields
          @subadm_xpath = './cda:entryRelationship/cda:substanceAdministration'
          # administrationTiming [frequency of drug - could be specific time, interval (every 6 hours), duration (infuse over 30 minutes) but e2e uses frequency only]
          @timing_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration'

          # check for PRN
          @prn_xpath =   "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:observation[cda:code/@code='PRNIND']/cda:value/@value"
          # check for LONG TERM MED
          @lt_xpath =    "./cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.3.1818.10.4.32']/cda:observation[cda:code/@code='UNBOUND']/cda:text/text()"
          # freeTextSig (Instructions to patient)
          @freetext_xpath_prefix  = "./cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:observation[cda:code[@code='INSTRUCT'] and cda:participant/cda:participantRole"
          @freetext_xpath_suffix1 = "/cda:code[@code='PAT'] ]/cda:text/text()"
          @freetext_xpath_suffix2 = "/@classCode='PAT' ]/cda:text/text()"
          # doseQuantity
          @dose_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:doseQuantity'
          # statusOfMedication (active, discharged, chronic, acute)
          @status_xpath = './cda:statusCode/@code'
          # route (by mouth, intravenously, topically, etc.)
          @route_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:routeCode'
          # productForm (tablet, capsule, liquid, ointment)
          @form_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:entryRelationship/cda:substanceAdministration/cda:administrationUnitCode'

          # location of embedded OrderInformation class fields
          @order_xpath   = './cda:entryRelationship/cda:substanceAdministration'
          # orderNumber (order identifier from perspective of ordering clinician)
          @orderno_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:id'
          # orderExpirationDateTime (Date when order is no longer valid)
          #@orderdate_expires_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:effectiveTime/cda:high'
          # orderDateTime (Date when order provider wrote the order/prescription)
          #@orderdate_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:author/cda:time'
          @orderdate_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:effectiveTime'
          # order provider
          @orderprovider_xpath = './cda:entryRelationship/cda:substanceAdministration/cda:author/cda:assignedAuthor/cda:assignedPerson/cda:name'

          @check_for_usable = true               # Pilot tools will set this to false
        end

        def create_entry(entry_element, id_map={})
          medication = Medication.new

          medication.administrationTiming={}
          medication.freeTextSig=''
          medication.dose={}
          #medication.typeOfMedication={}
          medication.statusOfMedication={}
          medication.longTerm=nil
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

          # check if this element has a null flavor, if it is we just 
          # return an empty medication which will result in the medication 
          # being ignored by the rest of the importer. 
          if test_null_flavor(entry_element, medication)
             medication
          else
                extract_description(entry_element, medication)
                extract_codes(entry_element, medication)
                extract_entry_value(entry_element, medication)
                extract_subadm_dates(entry_element, medication)

                extract_longterm_flag(entry_element, medication)

                extract_administration_timing(entry_element, medication)
                extract_freetextsig(entry_element, medication)
                extract_e2e_dose(entry_element, medication)
                extract_status(entry_element, medication)
                extract_route(entry_element, medication)
                extract_form(entry_element, medication)

                extract_order_information(entry_element, medication)
                extract_author_time(entry_element, medication)
                #extract_fulfillment_history(entry_element, medication)
                medication
            end 
        end

        private

        # Test for a case where the medication entry (substanceAdministration) is a flavor of null.
        #   return true if the nullFlavor attribute is set on the element, false otherwise. 
        def test_null_flavor(parent_element, entry)

          if parent_element.at_xpath("@nullFlavor")
            return true
          end 
          return false
        end 

        def extract_description(parent_element, entry)
          code_elements = parent_element.xpath(@description_xpath+'/e2e:desc/text()')
          if code_elements.size == 0 # fallback to using medication name
            code_elements = parent_element.xpath(@description_xpath+'/cda:name/text()')
          end
          code_elements.each do |code_element|
            entry.description = code_element
          end
        end

        # get medication strength value
        def extract_entry_value(parent_element, entry)
          #myscalar = parent_element.xpath(@strength_xpath+"/cda:center/@value").to_s
          myscalar = parent_element.xpath(@strength_xpath+"/@value").to_s
          #myunit = parent_element.xpath(@strength_xpath+"/cda:center/@unit").to_s
          myunit = parent_element.xpath(@strength_xpath+'/@unit').to_s
          if myscalar != "" && myunit != ""
            entry.set_value(myscalar,myunit)
          else # TODO clean this up, handles doseQuantity having the scalar value
            myvalue = {}
            if parent_element.at_xpath(@dose_xpath+'/cda:low/@value')
              myvalue['low'] = parent_element.xpath(@dose_xpath+'/cda:low/@value').to_s
              #myvalue['high'] = parent_element.xpath(@dose_xpath+"/cda:high/@value").to_s
              myvalue['unit'] = parent_element.xpath(@dose_xpath+"/cda:low/@unit").to_s
              entry.set_value(myvalue['low'],myvalue['unit'])
            elsif parent_element.at_xpath(@dose_xpath+'/cda:center/@value')
              myvalue['center'] = parent_element.xpath(@dose_xpath+'/cda:center/@value').to_s
              myvalue['unit'] = parent_element.xpath(@dose_xpath+"/cda:center/@unit").to_s
              entry.set_value(myvalue['center'],myvalue['unit'])
            end
          end

        end

      # Find date in Medication Prescription Event.
      def extract_subadm_dates(parent_element, entry, element_name="effectiveTime")
            
          parent_element = parent_element.xpath(@subadm_xpath)

          if parent_element.at_xpath("cda:#{element_name}")["nullFlavor"]

            entry.start_time = -2208985139 #this is Jan 1st 1900, it is basically guaranteed to make this an active medication provided the status field is "completed"
            entry.end_time = nil

          else
                if  parent_element.at_xpath("cda:#{element_name}/@value")
                  entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:#{element_name}")['value'])
                end
                if parent_element.at_xpath("cda:#{element_name}/cda:low")
                  entry.start_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:#{element_name}/cda:low")['value'])
                end
                if parent_element.at_xpath("cda:#{element_name}/cda:high")
                  entry.end_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:#{element_name}/cda:high")['value'])
                end
                if parent_element.at_xpath("cda:#{element_name}/cda:center")
                  entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:#{element_name}/cda:center")['value'])
                end
          end 
      end 

      def extract_longterm_flag(parent_element, entry)
          ltmed_element = parent_element.xpath(@lt_xpath).to_s
          unless ltmed_element.nil? || ltmed_element.empty?
            if ltmed_element.eql? "Long Term"
              entry.long_term = TRUE
            elsif ltmed_element.eql? "Short Term"
              entry.long_term = FALSE
            end
          end
      end

        # Handles drug administration timing expressed as a frequency,
        # interval, duration or specific time specification)
        def extract_administration_timing(parent_element, medication)
          ate = parent_element.xpath(@timing_xpath+'/cda:effectiveTime/cda:frequency')
          if ate
            at = {}
            at['numerator'] = extract_scalar(ate, "./cda:numerator")
            at['denominator'] = extract_scalar(ate, "./cda:denominator")
            medication.administration_timing['frequency'] = at
          end
          ate = parent_element.at_xpath(@timing_xpath+'/cda:effectiveTime/cda:period')
          if ate
            at = {}
            at['low'] = extract_scalar(ate, "./cda:low")
            at['high'] = extract_scalar(ate, "./cda:high")
            medication.administration_timing['period'] = at
          end
          ate = parent_element.at_xpath(@timing_xpath+'/cda:effectiveTime[cda:width]')
          if ate
            at = {}
            at['width'] = extract_scalar(ate, "./cda:width")
            medication.administration_timing['duration'] = at
          end
          #TODO - make sure the following actually works
          ate = parent_element.at_xpath(@timing_xpath+'/cda:effectiveTime[cda:low]')
          if ate
            at = {}
            at['low'] = extract_duration_fixed_dates(ate, "./cda:low")
            at['high'] = extract_duration_fixed_dates(ate, "./cda:high")
            medication.administration_timing['duration_dates'] = at
          end
          ate = parent_element.at_xpath(@timing_xpath+'/cda:doseQuantity/../cda:text/text()')
          if ate
            medication.administration_timing['text'] = ate.to_s
          end
        end

        def extract_duration_fixed_dates(parent_element, dates_xpath)
          date_element = parent_element.at_xpath(dates_xpath)
          if date_element
            {'inclusive' => date_element['inclusive'], 'value' => date_element['value']}
          else
            nil
          end
        end

        def extract_freetextsig(parent_element, entry)
          prn_element = parent_element.xpath(@prn_xpath).to_s
          if prn_element == "true"
            prnstr = " E2E_PRN_FLAG"
          else
            prnstr = ""
          end
          ltmedstr = ""
          ltmed_element = parent_element.xpath(@lt_xpath).to_s
          unless ltmed_element.nil? || ltmed_element.empty?
            if ltmed_element.eql? "Long Term"
              ltmedstr = " E2E_LONG_TERM_FLAG"
              #entry.long_term = TRUE
            end
          end
          entry.freeTextSig = parent_element.xpath(@freetext_xpath_prefix + @freetext_xpath_suffix1)
          if entry.freeTextSig == ''
            entry.freeTextSig = parent_element.xpath(@freetext_xpath_prefix + @freetext_xpath_suffix2)
          end
          entry.freeTextSig = entry.freeTextSig + prnstr + ltmedstr
        end

        # get medication count, extract_entry_value gets medication strength (value+unit)
        def extract_e2e_dose(parent_element, entry)
          # dose is counting number of pills, etc.  Shouldn't have units
          dose = {}
          if parent_element.at_xpath(@dose_xpath+'/cda:low/@value') &&
              parent_element.xpath(@dose_xpath+'/cda:low/@unit').size == 0
            dose['low'] = parent_element.xpath(@dose_xpath+'/cda:low/@value').to_s
            dose['high'] = parent_element.xpath(@dose_xpath+"/cda:high/@value").to_s
            #dose['unit'] = parent_element.xpath(@dose_xpath+'/cda:low/@unit').to_s
          elsif parent_element.at_xpath(@dose_xpath+'/cda:center/@value') &&
              parent_element.xpath(@dose_xpath+'/cda:center/@unit').size == 0
            dose['center'] = parent_element.xpath(@dose_xpath+'/cda:center/@value').to_s
            #dose['unit'] = parent_element.xpath(@dose_xpath+'/cda:center/@unit').to_s
          elsif parent_element.at_xpath(@dose_xpath+'/cda:center/@value') &&
              parent_element.xpath(@dose_xpath+'/cda:center/@unit').size == 1 &&
              parent_element.xpath(@dose_xpath+'/cda:center/@unit')[0] == 'Tablet(s)'
            dose['center'] = parent_element.xpath(@dose_xpath+'/cda:center/@value').to_s
          else
            dose = nil #has unit so will be parsed by extract_entry_value
          end
          entry.dose = dose
        end

        def extract_status(parent_element, entry)
          status_element = parent_element.xpath(@status_xpath)
          #STDERR.puts "status_element: " +status_element.inspect
          entry.statusOfMedication = {value: status_element.to_s}
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
          text_elements = parent_element.xpath(@route_xpath+"/cda:originalText/text()")
          text_elements.each do |text_element|
            entry.route['text'] = text_element.to_s
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

        def extract_order_information(parent_element, medication)
          order_elements = parent_element.xpath(@order_xpath)
          if order_elements
            order_elements.each do |order_element|
              order_information = OrderInformation.new
              order_information.prn = nil
              actor_element = order_element.at_xpath('./cda:author') #cda:author/cda:assignedAuthor/cda:assignedPerson/cda:name
              if actor_element
                order_information.performer = ProviderImporter.instance.extract_e2e_medication_provider(actor_element)
                # if order_information.performer.start
                #   order_information.orderDateTime =  order_information.performer.start
                # end
              end

              unless order_element.at_xpath('./cda:effectiveTime/cda:low').nil?
                #STDERR.puts "order_element ="+order_element.at_xpath('./cda:effectiveTime/cda:low').attr('value').inspect
                order_information.orderDateTime =HL7Helper.timestamp_to_integer(order_element.at_xpath('./cda:effectiveTime/cda:low').attr('value'))
              end
              
              unless order_element.at_xpath('./cda:effectiveTime/cda:high').nil?
                #STDERR.puts "order_element ="+order_element.at_xpath('./cda:effectiveTime/cda:high').attr('value').inspect
                order_information.orderExpirationDateTime = HL7Helper.timestamp_to_integer(order_element.at_xpath('./cda:effectiveTime/cda:high').attr('value'))
              end

              prn_element = order_element.xpath("./cda:entryRelationship/cda:observation[cda:code/@code='PRNIND']/cda:value/@value").to_s
              #STDERR.puts "PRN_ELEMENT: "+prn_element.inspect
              if prn_element == "true"
                order_information.prn = TRUE
              elsif prn_element == "false"
                order_information.prn = FALSE
              end
              #STDERR.puts "start = "+order_information.orderDateTime.inspect
              #STDERR.puts "end = "+order_information.orderExpirationDateTime.inspect
              #order_information.order_number = order_element.at_xpath('./cda:id').try(:[], 'root')
              #order_information.fills = order_element.at_xpath('./cda:repeatNumber').try(:[], 'value').try(:to_i)
              #order_information.quantity_ordered = extract_scalar(order_element, "./cda:quantity")

              medication.orderInformation << order_information
            end
          end
        end

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
