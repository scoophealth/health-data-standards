require 'test_helper'

class PatientImporterTest < MiniTest::Unit::TestCase
  def test_get_demographics
    doc = Nokogiri::XML(File.new('test/fixtures/scoop_basic_fragments/sample_scoop_basic.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    
    patient = Record.new
    HealthDataStandards::Import::ScoopBasic::PatientImporter.instance.get_demographics(patient, doc)

    assert_equal 'Henry', patient.first
    assert_equal 'Levin', patient.last
    assert_equal -1176163200 , patient.birthdate
    assert_equal 'M', patient.gender
    assert_equal '12345', patient.medical_record_number
    assert_equal 955065600 , patient.effective_time
    
  end
  
  def test_parse_scoop_basic
    doc = Nokogiri::XML(File.new('test/fixtures/scoop_basic_fragments/sample_scoop_basic.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    
    patient = HealthDataStandards::Import::ScoopBasic::PatientImporter.instance.parse_scoop_basic(doc)
    patient.save!
    
    assert_equal 'Henry', patient.first
  #  assert_equal 1, patient.encounters.size
    
  #  assert_equal 1270598400, patient.encounters.first.time
  end
end