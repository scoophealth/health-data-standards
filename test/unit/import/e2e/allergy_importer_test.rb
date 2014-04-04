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
    assert_equal allergy.codes, {"Unknown"=>["NA"]}
    assert_equal "MED", allergy.type['code']
    assert_equal "Medication", allergy.type['displayName']
    assert_equal "2.16.840.1.113883.5.4", allergy.type['codeSystem']
    assert_equal "HL7 ActCode", allergy.type['codeSystemName']
    assert_equal "", allergy.reaction['text']
    assert_equal nil, allergy.reaction['value']
    assert_equal nil, allergy.severity
    assert_equal 'C', allergy.status_code['PITO AllergyClinicalStatus'][0]
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
    assert_equal allergy.codes, {"SNOMED-CT"=>["256349002"]}
    assert_equal "FALG", allergy.type['code']
    assert_equal "Food Allergy", allergy.type['displayName']
    assert_equal "2.16.840.1.113883.5.4", allergy.type['codeSystem']
    assert_equal "HL7 ActCode", allergy.type['codeSystemName']
    assert_equal 'A4', allergy.severity['code']
    assert_equal 'Severe', allergy.severity['displayName']
    assert_equal '2.16.840.1.113883.5.1063', allergy.severity['codeSystem']
    assert_equal 'HL7 ObservationValue', allergy.severity['codeSystemName']
    assert_equal 'Severe reaction to peanuts', allergy.reaction['text']
    assert_equal '417516000', allergy.reaction['value']['code']
    assert_equal 'Anaphylaxis due to substance', allergy.reaction['value']['displayName']
    assert_equal '2.16.840.1.113883.6.96', allergy.reaction['value']['codeSystem']
    assert_equal 'SNOMED CT', allergy.reaction['value']['codeSystemName']

    assert_equal 'C', allergy.status_code['PITO AllergyClinicalStatus'][0]
    assert_equal Time.gm(2011,2,14).to_i, allergy.time

    allergy = patient.allergies[2]
    assert_equal true, allergy.nil?

  end
end
end