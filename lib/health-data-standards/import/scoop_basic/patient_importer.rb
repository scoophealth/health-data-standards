module HealthDataStandards
  module Import
    module ScoopBasic

      # This class is the central location for taking a SCOOP Basic XML document and converting it
      # into the processed form stored in MongoDB. The class does this by running each measure
      # independently on the XML document
      #
      # This class is a Singleton. It should be accessed by calling PatientImporter.instance
      class PatientImporter

        include Singleton
        include HealthDataStandards::Util

        # This is the most basic patient demographic information. The function is to test the interoperabilit of the tools. 
        #
        # 
        def initialize(check_usable = true)
          @section_importers = {}
          
        end

        def build_id_map(doc)
          id_map = {}
          path = "//*[@ID]"
          ids = doc.xpath(path)
          ids.each do |id|
            tag = id['ID']
            value = id.content
            id_map[tag] = value
          end

          id_map
        end

        # @param [boolean] value for check_usable_entries...importer uses true, stats uses false 
        def check_usable(check_usable_entries)
          @section_importers.each_pair do |section, importer|
            importer.check_for_usable = check_usable_entries
          end
        end

        # Parses a SCOOP Basic XML document and returns a Hash of of the patient.
        #
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        # @return [Record] a Mongoid model representing the patient
        def parse_scoop_basic(doc)
          scoop_patient = Record.new
          puts 'Before Get Demographics'
          get_demographics(scoop_patient, doc)
          puts 'After Get Demographics'
          create_scoop_basic_hash(scoop_patient, doc)
          
          scoop_patient
        end

        # Create a simple representation of the patient from a SCOOP Basic XML Document
        # @param [Record] record Mongoid model to append the Entry objects to
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        # @return [Hash] a represnetation of the patient with symbols as keys for each section
        def create_scoop_basic_hash(record, doc)
          id_map = build_id_map(doc)
          @section_importers.each_pair do |section, importer|
            record.send(section.to_setter, importer.create_entries(doc, id_map))
          end
        end

        # Inspects a SCOOP Basic document and populates the patient Hash with first name, last name
        # birth date, gender and the effectiveTime.
        #
        # @param [Hash] patient A hash that is used to represent the patient
        # @param [Nokogiri::XML::Node] doc The SCOOP Basic document parsed by Nokogiri
        def get_demographics(patient, doc)
          effective_date = doc.at_xpath('/cda:ClinicalDocument/cda:effectiveTime')['value']
          patient.effective_time = HL7Helper.timestamp_to_integer(effective_date)
          patient_element = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient')
          patient.first = patient_element.at_xpath('cda:name/cda:given').text
          patient.last = patient_element.at_xpath('cda:name/cda:family').text
          puts 'Before birthdate'
          birthdate_in_hl7ts_node = patient_element.at_xpath('cda:birthTime')
          birthdate_in_hl7ts = birthdate_in_hl7ts_node['value']
          patient.birthdate = HL7Helper.timestamp_to_integer(birthdate_in_hl7ts)
          gender_node = patient_element.at_xpath('cda:administrativeGenderCode')
          patient.gender = gender_node['code']
          id_node = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:id')
          patient.medical_record_number = id_node['extension']
        
        end
      end
    end
  end
end
