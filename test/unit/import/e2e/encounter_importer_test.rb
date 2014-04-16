require 'test_helper'

module E2E
  class EncounterImporterTest < MiniTest::Unit::TestCase
    def test_encounter_importing
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      assert_equal 0, patient.encounters.size
    end

    def test_complete_example_encounter_importing
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      assert_equal 1, patient.encounters.size

      encounter = patient.encounters[0]
      assert_equal 0, encounter.codes.size
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
