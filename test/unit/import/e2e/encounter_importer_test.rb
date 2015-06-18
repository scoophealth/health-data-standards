require 'test_helper'

module E2E
  class EncounterImporterTest < MiniTest::Unit::TestCase
    def test_encounter_importing
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)
      encounters = patient.encounters
      assert_equal 6, encounters.size
      assert_equal true, encounters[0].description.include?('130/85 sitting position')
      assert_equal Time.gm(2013,9,25,15,50,00).to_i, encounters[0].start_time #20130925155000  => 1380124200
      assert_equal Time.gm(2013,9,25,15,50,00).to_i, encounters[0].performer.start #20130925155000
      assert_equal Time.gm(2013,9,26,16,18,23).to_i, encounters[1].start_time
      assert_equal Time.gm(2013,9,26,16,18,23).to_i, encounters[1].performer.start
      assert_equal Time.gm(2013,9,26,16,19,01).to_i, encounters[2].start_time
      assert_equal Time.gm(2013,9,26,16,19,01).to_i, encounters[2].performer.start
      assert_equal Time.gm(2013,9,26,16,19,59).to_i, encounters[3].start_time
      assert_equal Time.gm(2013,9,26,16,19,59).to_i, encounters[3].performer.start
      assert_equal Time.gm(2013,9,26,16,20,10).to_i, encounters[4].start_time
      assert_equal Time.gm(2013,9,26,16,20,10).to_i, encounters[4].performer.start
      assert_equal Time.gm(2013,9,26,16,20,35).to_i, encounters[5].start_time
      assert_equal Time.gm(2013,9,26,16,20,35).to_i, encounters[5].performer.start

      encounters.each do |encounter|
        assert_equal "", encounter.performer.given_name
        assert_equal "qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==", encounter.performer.family_name
        assert_equal "", encounter.performer.npi
        #assert_equal "doctor", encounter.performer.given_name
        #assert_equal "oscardoc", encounter.performer.family_name
        #assert_equal "cpsid", encounter.performer.npi
        assert_equal "", encounter.performer.title #assert_nil encounter.performer.title
        refute_nil encounter.description
        refute_nil encounter.start_time
        #TODO update this when we have some proper codes
        assert_equal 2, encounter.codes.size
        assert_equal "REASON", encounter.codes['code'][0]
        assert_equal "ObservationType-CA-Pending", encounter.codes['codeSystem'][0]
      end

#        assert encounter.codes['CPT'].include? '99241'
#        assert_equal encounter.facility.name, 'Good Health Clinic'
#        assert_equal encounter.admit_type['code'], 'xyzzy'
#        assert_equal encounter.admit_type['codeSystem'], 'CPT'
#        assert_equal 'HL7 Healthcare Service Location', encounter.facility.code['codeSystem']
#        assert_equal Time.gm(2000, 4, 7).to_i, encounter.facility.start_time
#        assert_equal '1117-1', encounter.facility.code['code']
#        assert_equal '100 Bureau Drive', encounter.performer.addresses.first.street.first

    end

    def test_importing_complete_example
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      assert_equal 1, patient.encounters.size

      encounter = patient.encounters[0]
      assert_equal "", encounter.performer.title
      assert_equal "", encounter.performer.given_name
      assert_equal "z4hMj1x8RjceNv1Mdw/qNiCxMRnMob5d4SHNYQ==", encounter.performer.family_name
      assert_equal "", encounter.performer.npi
      #assert_equal "Mr.", encounter.performer.title
      #assert_equal "Encounter", encounter.performer.given_name
      #assert_equal "Provider", encounter.performer.family_name
      #assert_equal "155388", encounter.performer.npi
      assert_equal 2, encounter.codes.size
      assert_equal Time.gm(2011,2,14).to_i, encounter.time
      assert_equal 'General Medical Examination', encounter.description
      assert_nil encounter.facility.name
      assert_nil encounter.facility.code
      assert encounter.reason.codes['ObservationType-CA-Pending'].include? 'REASON'
      assert encounter.reason.codes['SNOMED-CT'].include? '37743000'
      assert_equal 'General Medical Examination', encounter.reason.description
    end

    def test_encounter_importing_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)
      encounters = patient.encounters
      assert_equal 3, encounters.size
      assert_equal true, encounters[0].description.include?('Cough and Fever')
      assert_equal Time.gm(2012,6,12,10,0,0).to_i, encounters[0].start_time
      assert_equal Time.gm(2012,6,12,10,0,0).to_i, encounters[0].performer.start
      assert_equal Time.gm(2012,12,15).to_i, encounters[1].start_time
      assert_equal Time.gm(2012,12,15).to_i, encounters[1].performer.start
      assert_equal Time.gm(2012,12,20,14,0).to_i, encounters[2].start_time
      assert_equal Time.gm(2012,12,20,14,0).to_i, encounters[2].performer.start

      assert_equal '723CDj1qKtsyu1RWPnBZZ4xV+24qZMoEYh/BuQ==', encounters[0].performer.family_name
      assert_equal '723CDj1qKtsyu1RWPnBZZ4xV+24qZMoEYh/BuQ==', encounters[1].performer.family_name
      assert_equal 'uEFPPUFw3c7CDbHqEc96WJlAffuarPOnsUFbnw==', encounters[2].performer.family_name

      encounters.each do |encounter|
        assert_equal "", encounter.performer.given_name
        assert_equal "", encounter.performer.npi
        assert_equal "", encounter.performer.title #assert_nil encounter.performer.title
        refute_nil encounter.description
        refute_nil encounter.start_time
        #TODO update this when we have some proper codes
        assert_equal 2, encounter.codes.size
        assert_equal "REASON", encounter.codes['code'][0]
        assert_equal "ObservationType-CA-Pending", encounter.codes['codeSystem'][0]
      end

    end

    def test_encounter_importing_zarilla2
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla2.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)
      encounters = patient.encounters
      assert_equal 3, encounters.size
      assert_equal true, encounters[0].description.include?('Cough and Fever')
      assert_nil encounters[0].start_time
      assert_equal Time.gm(2012,6,12,10,0,0).to_i, encounters[0].performer.start
      assert_equal Time.gm(2012,12,15).to_i, encounters[1].start_time
      assert_equal Time.gm(2012,12,15).to_i, encounters[1].performer.start
      assert_equal Time.gm(2012,12,20,14,0).to_i, encounters[2].start_time
      assert_equal Time.gm(2012,12,20,14,0).to_i, encounters[2].performer.start

      assert_equal '723CDj1qKtsyu1RWPnBZZ4xV+24qZMoEYh/BuQ==', encounters[0].performer.family_name
      assert_equal '723CDj1qKtsyu1RWPnBZZ4xV+24qZMoEYh/BuQ==', encounters[1].performer.family_name
      assert_equal 'uEFPPUFw3c7CDbHqEc96WJlAffuarPOnsUFbnw==', encounters[2].performer.family_name

      encounters.each do |encounter|
        assert_equal "", encounter.performer.given_name
        assert_equal "", encounter.performer.npi
        assert_equal "", encounter.performer.title #assert_nil encounter.performer.title
        refute_nil encounter.description
        #TODO update this when we have some proper codes
        assert_equal 2, encounter.codes.size
        assert_equal "REASON", encounter.codes['code'][0]
        assert_equal "ObservationType-CA-Pending", encounter.codes['codeSystem'][0]
      end
    end

    def test_encounter_with_null_start_and_end_times 
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla3.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)
      encounters = patient.encounters
      assert_equal 3, encounters.size

      assert_nil encounters[0].start_time
      assert_nil encounters[0].end_time


      assert_nil encounters[1].start_time
      assert_nil encounters[1].end_time
    end

    end


end
