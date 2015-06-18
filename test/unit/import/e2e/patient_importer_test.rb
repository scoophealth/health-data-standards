# This test can be run individually using:
# bundle exec ruby -Ilib:test test/unit/import/e2e/patient_importer_test.rb

require 'test_helper'

module E2E # to ensure no problems with minitest involving duplicated method names for test
  class PatientImporterTest < MiniTest::Unit::TestCase



    def setup
    end

    def test_get_demographics
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_demographics(patient, doc)


      assert_equal 'JOHN', patient.first
      assert_equal 'CLEESE', patient.last
      assert_equal -923616000, patient.birthdate
      assert_equal 'M', patient.gender
      assert_equal '448000001', patient.medical_record_number
      assert_equal Time.gm(2014,6,12,13,18,0).to_i, patient.effective_time
      assert_equal ['EN'], patient.languages

    end

    def test_get_demographics_no
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_demographics_no(patient, doc)
      assert_equal "1", patient.emr_demographics_primary_key
    end

    def test_get_primary_care_provider_id
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_primary_care_provider_id(patient, doc)
      assert_equal "cpsid", patient.primary_care_provider_id
    end

    def test_get_demographics_complete_example
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_demographics(patient, doc)

      assert_equal 'Eve', patient.first
      assert_equal 'Everywoman', patient.last
      assert_equal Time.gm(1947,5,16).to_i, patient.birthdate
      assert_equal 'F', patient.gender
      assert_equal '9999999999', patient.medical_record_number
      assert_equal Time.gm(2012,1,9,14,22,0).to_i, patient.effective_time
      assert_equal ['EN'], patient.languages
    end


    def test_get_demographics_no_complete_example
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_demographics_no(patient, doc)
      assert_equal "12345", patient.emr_demographics_primary_key
    end

    def test_get_primary_care_provider_id_complete_example
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_primary_care_provider_id(patient, doc)
      assert_equal "38809", patient.primary_care_provider_id
    end

    def test_get_demographics_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_demographics(patient, doc)

      assert_equal 'Melvin', patient.first
      assert_equal 'Zarilla', patient.last
      assert_equal Time.gm(2011,4,9).to_i, patient.birthdate
      assert_equal 'F', patient.gender
      assert_equal '9698686174', patient.medical_record_number
      assert_equal Time.gm(2014,9,9,9,47,20).to_i, patient.effective_time
      assert_nil patient.languages
    end


    def test_get_demographics_no_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_demographics_no(patient, doc)
      assert_equal nil, patient.emr_demographics_primary_key
    end

    def test_get_primary_care_provider_id_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = Record.new
      HealthDataStandards::Import::E2E::PatientImporter.instance.get_primary_care_provider_id(patient, doc)
      assert_equal '91604', patient.primary_care_provider_id
    end


    def test_parse_e2e
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = HealthDataStandards::Import::E2E::PatientImporter.instance.parse_e2e(doc)
      patient.save!

      assert_equal 'JOHN', patient.first
      assert_equal 6, patient.encounters.size
      #assert ! patient.expired

      assert_equal 1380124200, patient.encounters.first.start_time
    end

    def test_parse_e2e_complete_example
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = HealthDataStandards::Import::E2E::PatientImporter.instance.parse_e2e(doc)
      patient.save!

      assert_equal 'Eve', patient.first
      assert_equal 1, patient.encounters.size
      #assert ! patient.expired

      assert_equal Time.gm(2011,2,14).to_i, patient.encounters.first.time
    end

    def test_parse_e2e2_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = HealthDataStandards::Import::E2E::PatientImporter.instance.parse_e2e(doc)
      patient.save!

      assert_equal 'Melvin', patient.first
      assert_equal 3, patient.encounters.size
      assert_equal 5, patient.conditions.size
      #assert ! patient.expired

      assert_equal 1339495200, patient.encounters.first.start_time
      assert_nil patient.encounters.first.time
    end

    def test_expired
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = HealthDataStandards::Import::E2E::PatientImporter.instance.parse_e2e(doc)
      patient.save!
      assert_equal 4, patient.conditions.size
      #assert patient.expired

    end

    def test_nullflavour_birthdate
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla3.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      patient = HealthDataStandards::Import::E2E::PatientImporter.instance.parse_e2e(doc)
      patient.save!
      assert_equal nil, patient.birthdate

    end
  end
end