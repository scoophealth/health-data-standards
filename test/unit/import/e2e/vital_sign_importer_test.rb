require 'test_helper'

module E2E
class VitalSignImporterTest < MiniTest::Unit::TestCase

  def test_vital_sign_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    assert_equal 7, patient.vital_signs.size

    vital_sign = patient.vital_signs[0]
    assert_equal Time.gm(2013,9,25,0,0,0).to_i, vital_sign.time
    assert_equal "Systolic Blood Pressure (sitting position)", vital_sign.description
    assert_equal "130", vital_sign.values.first.scalar
    assert_equal "mm[Hg]", vital_sign.values.first.units
    assert_equal nil, vital_sign.interpretation

    vital_sign = patient.vital_signs[1]
    assert_equal Time.gm(2013,9,25,0,0,0).to_i, vital_sign.time
    assert_equal "Diastolic Blood Pressure (sitting position)", vital_sign.description
    assert_equal "85", vital_sign.values.first.scalar
    assert_equal "mm[Hg]", vital_sign.values.first.units
    assert_equal nil, vital_sign.interpretation

    vital_sign = patient.vital_signs[2]
    assert_equal Time.gm(2013,9,25,0,0,0).to_i, vital_sign.time
    assert_equal "Height (in cm)", vital_sign.description
    assert_equal "187", vital_sign.values.first.scalar
    assert_equal "cm", vital_sign.values.first.units
    assert_equal nil, vital_sign.interpretation

    vital_sign = patient.vital_signs[3]
    assert_equal Time.gm(2013,9,25,0,0,0).to_i, vital_sign.time
    assert_equal "Heart Rate (in bpm (nnn) Range:40-180)", vital_sign.description
    assert_equal "85", vital_sign.values.first.scalar
    assert_equal "beats/min", vital_sign.values.first.units

    vital_sign = patient.vital_signs[4]
    assert_equal Time.gm(2013,9,25,0,0,0).to_i, vital_sign.time
    assert_equal "Temperature (degrees celcius)", vital_sign.description
    assert_equal "37", vital_sign.values.first.scalar
    assert_equal "C", vital_sign.values.first.units


    vital_sign = patient.vital_signs[5]
    assert_equal Time.gm(2013,9,25,0,0,0).to_i, vital_sign.time
    assert_equal "Waist (Waist Circum in cm)", vital_sign.description
    assert_equal "92", vital_sign.values.first.scalar
    assert_equal "cm", vital_sign.values.first.units

    vital_sign = patient.vital_signs[6]
    assert_equal Time.gm(2013,9,25,0,0,0).to_i, vital_sign.time
    assert_equal "Weight (in kg)", vital_sign.description
    assert_equal "95", vital_sign.values.first.scalar
    assert_equal "kg", vital_sign.values.first.units

  end


  def test_complete_example_vital_sign_importing
    doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    assert_equal 5, patient.vital_signs.size

    vital_sign = patient.vital_signs[0]
    code_system = vital_sign.codes.keys[0]
    assert_equal "LOINC", code_system
    assert_equal ["8480-6"], vital_sign.codes[code_system]
    assert_equal Time.gm(2012,1,13).to_i, vital_sign.time
    refute_nil vital_sign.interpretation
    assert_equal 'N', vital_sign.interpretation['code']
    assert_equal 'HITSP C80 Observation Status', vital_sign.interpretation['codeSystem']   #from code_system_helper.rb
    assert_equal "124", vital_sign.values.first.scalar
    assert_equal "mm[Hg]", vital_sign.values.first.units

    vital_sign = patient.vital_signs[1]
    code_system = vital_sign.codes.keys[0]
    assert_equal "LOINC", code_system
    assert_equal ["8462-4"], vital_sign.codes[code_system]
    assert_equal Time.gm(2012,1,13).to_i, vital_sign.time
    refute_nil vital_sign.interpretation
    assert_equal 'N', vital_sign.interpretation['code']
    assert_equal 'HITSP C80 Observation Status', vital_sign.interpretation['codeSystem']   #from code_system_helper.rb
    assert_equal "64", vital_sign.values.first.scalar
    assert_equal "mm[Hg]", vital_sign.values.first.units

    vital_sign = patient.vital_signs[2]
    code_system = vital_sign.codes.keys[0]
    assert_equal "LOINC", code_system
    assert_equal ["8302-2"], vital_sign.codes[code_system]
    assert_equal Time.gm(2012,1,13).to_i, vital_sign.time
    assert_equal nil, vital_sign.interpretation
    assert_equal "190", vital_sign.values.first.scalar
    assert_equal "cm", vital_sign.values.first.units

    vital_sign = patient.vital_signs[3]
    code_system = vital_sign.codes.keys[0]
    assert_equal "LOINC", code_system
    assert_equal ["3141-9"], vital_sign.codes[code_system]
    assert_equal Time.gm(2012,1,13).to_i, vital_sign.time
    assert_equal nil, vital_sign.interpretation
    assert_equal "48", vital_sign.values.first.scalar
    assert_equal "kg", vital_sign.values.first.units

    vital_sign = patient.vital_signs[4]
    code_system = vital_sign.codes.keys[0]
    assert_equal "LOINC", code_system
    assert_equal ["56115-9"], vital_sign.codes[code_system]
    assert_equal Time.gm(2012,1,13).to_i, vital_sign.time
    assert_equal nil, vital_sign.interpretation
    assert_equal "120", vital_sign.values.first.scalar
    assert_equal "cm", vital_sign.values.first.units
    assert_equal "Waist circumference", vital_sign.description
  end

  end
end
