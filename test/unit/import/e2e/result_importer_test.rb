require 'test_helper'

module E2E
  class ResultImporterTest < MiniTest::Unit::TestCase
    def test_result_importing
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      refute_nil patient
      refute_nil patient.results
      assert_equal 28, patient.results.size

      result = patient.results[15]
      refute_nil result

      assert_equal 1, result.codes.keys.size
      code_system = result.codes.keys[0]
      assert_equal "Glucose Random", result.description
      assert_equal "pCLOCD", code_system
      assert_equal ['14749-6'], result.codes[code_system]

      refute_nil result.values
      assert_nil result.free_text
      assert_equal "5.2", result.values.first.scalar
      assert_equal "mmol/L", result.values.first.units

      assert_equal "Normal Reference range is greater than 3.3", result.reference_range
      assert_equal "complete", result.status_code[:value]
      assert_equal Time.gm(2013,5,31,10,20,12).to_i, result.start_time

      interpretation_code_system = result.interpretation.keys[0]
      assert_equal "code", interpretation_code_system
      assert_equal 'N', result.interpretation['code']
      assert_equal 'ObservationInterpretation', result.interpretation['codeSystem']
    end

    def test_result_importing_complete_example
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      refute_nil patient
      refute_nil patient.results
      assert_equal 1, patient.results.size

      result = patient.results[0]
      refute_nil result

      assert_equal 1, result.codes.keys.size
      code_system = result.codes.keys[0]
      assert_equal "LOINC", code_system
      assert_equal ['6690-2'], result.codes[code_system]

      refute_nil result.values
      assert_equal 1, result.values.size
      assert_equal "6.7", result.values.first.scalar
      assert_equal "10+3/ul", result.values.first.units

      assert_equal "Normal Reference range is between 5 and 10; High Reference range is between 5 and 10; Very High Reference range is between 5 and 10; ", result.reference_range
      assert_equal "final", result.status_code[:value]

      assert_equal Time.gm(2010,1,27).to_i, result.time

      interpretation_code = result.interpretation.keys[0]
      assert_equal "code", interpretation_code
      assert_equal "N", result.interpretation['code']

      assert_equal 'ObservationInterpretation', result.interpretation['codeSystem']
    end

    def test_result_importing_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      refute_nil patient
      refute_nil patient.results
      assert_equal 59, patient.results.size

      result = patient.results[15]
      refute_nil result

      assert_equal 1, result.codes.keys.size
      code_system = result.codes.keys[0]
      assert_equal "Glucose Fasting", result.description
      assert_equal "pCLOCD", code_system
      assert_equal ['14771-0'], result.codes[code_system]

      refute_nil result.values
      assert_equal 0, result.values.size
      refute_nil result.free_text
      assert_equal '4.8 mmol/L', result.free_text
      #assert_equal "4.8", result.values.first.scalar
      #assert_equal "mmol/L", result.values.first.units

      assert_equal "3.3-5.5", result.reference_range
      assert_equal "", result.status_code[:value]
      assert_equal Time.gm(2012,3,12,17,50,6).to_i, result.start_time

      refute_nil result.interpretation
      interpretation_code_system = result.interpretation.keys[0]
      assert_equal "code", interpretation_code_system
      assert_equal 'N', result.interpretation['code']
      # TODO - verify that Osler and Oscar are using the correct codeSystem
      # assert_equal 'ObservationInterpretation', result.interpretation['codeSystem']

      # One nullFlavor observation is present in patient lab results
      assert_equal 0, patient.results[30].codes.size
    end

    def test_null_flavor_times

      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla3.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      result = patient.results[0]      
      code_system = result.codes.keys[0]
      assert_equal ["6690-2"], result.codes[code_system]

      assert_nil result.start_time
      assert_nil result.time

      result = patient.results[1]      
      code_system = result.codes.keys[0]
      assert_equal ["789-8"], result.codes[code_system]

      assert_nil result.start_time
      assert_nil result.time


    end
  end
end
