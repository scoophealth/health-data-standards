require 'test_helper'

module E2E
class VitalSignImporterTest < MiniTest::Unit::TestCase

  def test_vital_sign_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    assert_equal 6, patient.vital_signs.size
    vital_sign = patient.vital_signs[0]

    assert_equal Time.gm(2013,5,8,0,0,0).to_i, vital_sign.time
    assert_equal "Blood Pressure (sitting position)", vital_sign.description
    assert_equal "130/85", vital_sign.free_text

    #assert_equal 'N', vital_sign.interpretation['code']
    #assert_equal "177", vital_sign.values.first.scalar
    #assert_equal "cm", vital_sign.values.first.units
    #assert_equal 'HITSP C80 Observation Status', vital_sign.interpretation['codeSystem']
  end


  def test_complete_example_vital_sign_importing
    doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    assert_equal 1, patient.vital_signs.size
    vital_sign = patient.vital_signs[0]

    #vital_sign = patient.vital_signs[0]

    #assert_equal 'N', vital_sign.interpretation['code']
    #assert_equal "177", vital_sign.values.first.scalar
    #assert_equal "cm", vital_sign.values.first.units
    #assert_equal 'HITSP C80 Observation Status', vital_sign.interpretation['codeSystem']

    #assert_equal "LOINC", code_system
    #assert_equal ["14647-2"], result.codes[code_system]

    #translation = result.codes.keys[1]

    #assert_equal "SNOMED-CT", translation
    #assert_equal ["12345"], result.codes[translation]

    #assert_equal 135, result.values.first.scalar
    #assert_equal "mg/dl", result.values.first.units

    #assert_equal "<200 mg/dl", result.reference_range
    #assert_equal "completed", result.status

    #assert_equal Time.parse('2012-01-30T09:00:00').utc.to_i, result.time

    #refute_nil result.interpretation

    #interpretation_code_system = result.interpretation.keys[0]

    #assert_equal "HITSP C80 Observation Status", interpretation_code_system
    #assert_equal ["N"], result.interpretation[interpretation_code_system]


    assert_equal Time.gm(2012,1,13,0,0,0).to_i, vital_sign.time
    assert_equal "Waist circumference", vital_sign.description
    assert_equal "", vital_sign.free_text
  end

  end
end
