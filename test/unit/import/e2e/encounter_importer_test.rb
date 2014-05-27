require 'test_helper'

module E2E
  class EncounterImporterTest < MiniTest::Unit::TestCase
    def test_encounter_importing
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)
      encounters = patient.encounters
      assert_equal 2, encounters.size
      assert_equal "Multivitamin", encounters[0].description
      assert_equal Time.gm(2013,9,26,16,24,15).to_i, encounters[0].time #20130926162415
      encounters.each do |encounter|
        assert_equal "doctor", encounter.performer.given_name
        assert_equal "oscardoc", encounter.performer.family_name
        assert_equal "999998", encounter.performer.npi
        assert_nil encounter.performer.title
        refute_nil encounter.description
        refute_nil encounter.time
        #TODO update date this when we have some proper codes
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

    def test_complete_example_encounter_importing
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      assert_equal 1, patient.encounters.size

      encounter = patient.encounters[0]
      assert_equal "Mr.", encounter.performer.title
      assert_equal "Encounter", encounter.performer.given_name
      assert_equal "Provider", encounter.performer.family_name
      assert_equal "155388", encounter.performer.npi
      assert_equal 2, encounter.codes.size
      assert_equal Time.gm(2011,2,14).to_i, encounter.time
      assert_equal 'General Medical Examination', encounter.description
      assert_nil encounter.facility.name
      assert_nil encounter.facility.code
      assert encounter.reason.codes['ObservationType-CA-Pending'].include? 'REASON'
      assert encounter.reason.codes['SNOMED-CT'].include? '37743000'
      assert_equal 'General Medical Examination', encounter.reason.description
    end
  end
end
