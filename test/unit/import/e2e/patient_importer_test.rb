# This test can be run individually using:
# bundle exec ruby -Ilib:test test/unit/import/e2e/patient_importer_test.rb

require 'test_helper'

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
    assert_equal '000000000', patient.medical_record_number
    assert_equal 1366710180, patient.effective_time

  end

  def test_parse_e2e
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    
    patient = HealthDataStandards::Import::E2E::PatientImporter.instance.parse_e2e(doc)
    patient.save!

    assert_equal 'JOHN', patient.first
    assert_equal 0, patient.encounters.size
    #assert ! patient.expired

    #assert_equal 1270598400, patient.encounters.first.time
  end

  def test_expired
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    
    patient = HealthDataStandards::Import::E2E::PatientImporter.instance.parse_e2e(doc)
    #patient.save!
    #assert_equal 1, patient.conditions.size
    #assert patient.expired

  end
end
