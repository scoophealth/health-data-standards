require 'test_helper'

module E2E
class AllergyImporterTest < MiniTest::Unit::TestCase
  def test_allergy_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    allergy = patient.allergies[0]
    assert_equal false, allergy.nil?
    assert_equal 'PENICILLINS, COMBINATIONS WITH OTHER ANTIBACTERIAL', allergy.description
    #assert_equal 'MI', allergy.severity['code']
    #John Cleese no longer has a valid code after Jeremy's July 31, 2013 update.
    assert_equal nil, allergy.severity['code']
    assert_equal nil, allergy.reaction
    assert_equal 'C', allergy.status_code['PITO AlleryClinicalStatus'][0]
    assert_equal Time.gm(2013,3,5).to_i, allergy.time

    allergy = patient.allergies[2]
    assert_equal true, allergy.nil?

  end

  def test_complete_example_allergy_importing
    doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    assert_equal 1, patient.allergies.size
    allergy = patient.allergies[0]
    assert_equal false, allergy.nil?
    assert_equal 'Peanut allergy', allergy.description
    assert_equal 'A4', allergy.severity['code']
    assert_equal nil, allergy.reaction['code']
    assert_equal 'C', allergy.status_code['PITO AlleryClinicalStatus'][0]
    assert_equal Time.gm(2011,2,14).to_i, allergy.time

    allergy = patient.allergies[2]
    assert_equal true, allergy.nil?

  end
end
end