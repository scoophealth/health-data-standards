require 'test_helper'

module E2E
class ResultImporterTest < MiniTest::Unit::TestCase
  def test_result_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)
    patient.save!

    refute_nil patient
    refute_nil patient.results
    assert_equal 50, patient.results.size

    result = patient.results[0]
    refute_nil result

    assert_equal 1, result.codes.keys.size
    code_system = result.codes.keys[0]
    assert_equal "LOINC", code_system
    assert_equal ['31208-2'], result.codes[code_system]

    refute_nil result

    #code_system = result.codes.keys[0]
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

    #interpretation_code_system = result.interpretation.keys[0]
    #assert_equal "HITSP C80 Observation Status", interpretation_code_system
    #assert_equal ["N"], result.interpretation[interpretation_code_system]

    #assert_equal 135, result.values.first.scalar
    #assert_equal 'lb', result.values.first.unit
    #assert_equal 'xyz', result.values.inspect
    assert_equal 'N', result.interpretation['code']
    assert_equal nil, result.interpretation['codeSystem']
  end
end
end
