# Tests can be run individually using:
# bundle exec ruby -Ilib:test test/unit/import/e2e/medication_importer_test.rb
require 'test_helper'

module E2E
class MedicationImporterTest < MiniTest::Unit::TestCase
  def test_medication_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    patient.save!

    # first listed medication
    medication = patient.medications[0]
    assert_equal "TYLENOL EXTRA STRENGTH TAB 500MG", medication.description

    assert medication.codes['HC-DIN'].include? '00559407'
    assert medication.codes['whoATC'].include? 'N02BE01'

    assert_equal "500.0", medication.values.first.scalar
    assert_equal "MG", medication.values.first.units

    assert_equal Time.gm(2013,3,5).to_i, medication.time
    assert_equal Time.gm(2013,3,5).to_i, medication.start_time
    assert_equal Time.gm(2013,4,24).to_i, medication.end_time

    assert_equal 4, medication.administration_timing['frequency']['numerator']['value']
    assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
    assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

    assert_equal '', medication.freeTextSig

    assert_equal '1.0', medication.dose['low']
    assert_equal '2.0', medication.dose['high']

    assert_equal 'active', medication.statusOfMedication[:value]

    assert_equal 'PO', medication.route['code']
    assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
    assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
    assert_equal 'PO', medication.route['displayName']

    assert_equal 'TAB', medication.product_form['code']
    assert_equal '2.16.840.1.113883.1.11.14570', medication.product_form['codeSystem']
    assert_equal 'TABLET', medication.product_form['displayName']


    # last listed medication
    medication = patient.medications[8]
    assert_equal "ATORVASTATIN 40MG", medication.description

    assert medication.codes['HC-DIN'].include? '02387913'
    assert medication.codes['whoATC'].include? 'C10AA05'

    assert_equal "40.0", medication.values.first.scalar
    assert_equal "MG", medication.values.first.units

    assert_equal 1362441600, medication.time   # returns nil?
    assert_equal 1362441600, medication.start_time
    assert_equal 1367280000, medication.end_time

    assert_equal 1, medication.administration_timing['frequency']['numerator']['value']
    assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
    assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

    assert_equal '', medication.freeTextSig

    assert_equal '1.0', medication.dose['low']
    assert_equal '1.0', medication.dose['high']

    assert_equal 'active', medication.statusOfMedication[:value]

    assert_equal 'PO', medication.route['code']
    assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
    assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
    assert_equal 'PO', medication.route['displayName']

    assert_equal 'TAB', medication.product_form['code']
    assert_equal '2.16.840.1.113883.1.11.14570', medication.product_form['codeSystem']
    assert_equal 'TABLET', medication.product_form['displayName']
  end

  def test_complete_example_medication_importing
    doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    patient.save!

    # first listed medication
    medication = patient.medications[0]
    assert_equal "NITROGLYCERIN 0.4 mg/dose SPRAY, NON-AEROSOL (GRAM)", medication.description

    assert medication.codes['HC-DIN'].include? '02243588'

    assert_equal "0.4", medication.values.first.scalar
    assert_equal "mg", medication.values.first.units

    #TODO - Nail down what the medication.time refers to exactly
    assert_equal Time.gm(2003,5,29).to_i, medication.time
    assert_equal Time.gm(2013,2,11).to_i, medication.start_time
    assert_equal Time.gm(2013,2,12).to_i, medication.end_time

    #TODO - fix administration timing for general case
    assert medication.administration_timing != nil
    assert_equal 'xyz', medication.administration_timing.inspect
    #assert_equal 4, medication.administration_timing['frequency']['numerator']['value']
    #assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
    #assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

    #TODO - fix freeTextSig
    text1 = "One spray every 5 minutes as needed for chest discomfort."
    assert medication.freeTextSig.include? text1
    text2 = "If pain continues for more than 15 minutes or recurs frequently, get to emergency department ASAP."
    assert medication.freeTextSig.include? text2

    assert_equal '325', medication.dose['low']
    assert_equal '650', medication.dose['high']

    assert_equal 'active', medication.statusOfMedication[:value]

    assert_equal 'PO', medication.route['code']
    assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
    assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
    assert_equal 'per os', medication.route['displayName']

    assert_equal 'ORSPRAY', medication.product_form['code']
    assert_equal '2.16.840.1.113883.1.11.14570', medication.product_form['codeSystem']
    assert_equal 'oral spray', medication.product_form['displayName']

  end
end
end
