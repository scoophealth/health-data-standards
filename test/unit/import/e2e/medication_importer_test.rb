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


      # number of medication sections
      assert_equal 9, patient.medications.size

      # first listed medication
      medication = patient.medications[0]
      assert_equal "TYLENOL EXTRA STRENGTH TAB 500MG", medication.description

      assert medication.codes['HC-DIN'].include? '00559407'
      assert medication.codes['whoATC'].include? 'N02BE01'

      assert_equal "500.0", medication.values.first.scalar
      assert_equal "MG", medication.values.first.units

      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,16).to_i, medication.end_time

      assert_equal 4, medication.administration_timing['frequency']['numerator']['value']
      assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
      assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

      assert_equal TRUE, medication.longTerm
      assert_equal ' E2E_PRN_FLAG E2E_LONG_TERM_FLAG', medication.freeTextSig

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

      assert_equal 1, medication.order_information.size
      assert_equal TRUE, medication.order_information[0].prn
      #assert_equal 1, medication.order_information.first.fills
      #assert_equal 1, medication.order_information.first.quantity_ordered['value']
      #assert_equal 'tablet', medication.order_information.first.quantity_ordered['unit']
      assert_equal '', medication.order_information[0].performer.given_name
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal '', medication.order_information[0].performer.npi

      # second listed medication (check what, when, who provided)
      medication = patient.medications[1]
      assert medication.codes['HC-DIN'].include? '00613215'
      assert medication.codes['whoATC'].include? 'C03DA01'
      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,22).to_i, medication.end_time
      assert_equal 1, medication.order_information.size
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal TRUE, medication.longTerm
      assert_equal FALSE, medication.order_information[0].prn
      assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig

      # third listed medication (check what, when, who provided)
      medication = patient.medications[2]
      assert medication.codes['HC-DIN'].include? '00636533'
      assert medication.codes['whoATC'].include? 'M01AE01'
      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,22).to_i, medication.end_time
      assert_equal 1, medication.order_information.size
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal TRUE, medication.longTerm
      assert_equal TRUE, medication.order_information[0].prn
      assert_includes medication.freeTextSig, ' E2E_PRN_FLAG E2E_LONG_TERM_FLAG'




      # fourth listed medication (check what, when, who provided)
      medication = patient.medications[3]
      assert medication.codes['HC-DIN'].include? '02041421'
      assert medication.codes['whoATC'].include? 'N05BA06'
      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,6).to_i, medication.end_time
      assert_equal 1, medication.order_information.size
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal TRUE, medication.longTerm
      assert_equal TRUE, medication.order_information[0].prn
      assert_equal ' E2E_PRN_FLAG E2E_LONG_TERM_FLAG', medication.freeTextSig


      # fifth listed medication (check what, when, who provided)
      medication = patient.medications[4]
      assert medication.codes['HC-DIN'].include? '02244993'
      assert medication.codes['whoATC'].include? 'B01AC06'
      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,22).to_i, medication.end_time
      assert_equal 1, medication.order_information.size
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal TRUE, medication.longTerm
      assert_equal FALSE, medication.order_information[0].prn
      assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig

      # sixth listed medication (check what, when, who provided)
      medication = patient.medications[5]
      assert medication.codes['HC-DIN'].include? '02351420'
      assert medication.codes['whoATC'].include? 'C03CA01'
      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2014,1,17).to_i, medication.end_time
      assert_equal 1, medication.order_information.size
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal TRUE, medication.longTerm
      assert_equal FALSE, medication.order_information[0].prn
      assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig


      # seventh listed medication (check what, when, who provided)
      medication = patient.medications[6]
      assert medication.codes['HC-DIN'].include? '02363283'
      assert medication.codes['whoATC'].include? 'C09AA05'
      refute medication.codes['whoATC'].include? 'C03CA01'
      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,22).to_i, medication.end_time
      assert_equal 1, medication.order_information.size
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal TRUE, medication.longTerm
      assert_equal FALSE, medication.order_information[0].prn
      assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig


      # eighth listed medication (check what, when, who provided)
      medication = patient.medications[7]
      assert medication.codes['HC-DIN'].include? '02364948'
      assert medication.codes['whoATC'].include? 'C07AG02'
      refute medication.codes['whoATC'].include? 'C03CA01'
      assert_equal Time.gm(2013,9,27).to_i, medication.time
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,22).to_i, medication.end_time
      assert_equal 1, medication.order_information.size
      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal TRUE, medication.longTerm
      assert_equal FALSE, medication.order_information[0].prn
      assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig

      # ninth and last listed medication
      medication = patient.medications[8]
      assert_equal "ATORVASTATIN 40MG", medication.description

      assert medication.codes['HC-DIN'].include? '02387913'
      assert medication.codes['whoATC'].include? 'C10AA05'

      assert_equal "40.0", medication.values.first.scalar
      assert_equal "MG", medication.values.first.units

      assert_equal Time.gm(2013,9,27).to_i, medication.time   # returns nil?
      assert_equal Time.gm(2013,9,27).to_i, medication.start_time
      assert_equal Time.gm(2013,11,22).to_i, medication.end_time

      assert_equal 1, medication.administration_timing['frequency']['numerator']['value']
      assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
      assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

      assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,9,27).to_i, medication.order_information[0].performer.start
      assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
      assert_equal 1, medication.order_information.size
      assert_equal TRUE, medication.longTerm
      assert_equal FALSE, medication.order_information[0].prn
      assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig

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

      # loop through all medications
      patient.medications.each do |medication|
        assert_equal 1, medication.order_information.size
        assert_equal '', medication.order_information[0].performer.given_name
        assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', medication.order_information[0].performer.family_name
        assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
        assert_equal '', medication.order_information[0].performer.npi
      end
    end

=begin
    def test_medication_importing_big
        doc = Nokogiri::XML(File.new('test/fixtures/TEST_PATIENT.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        pi = HealthDataStandards::Import::E2E::PatientImporter.instance
        patient = pi.parse_e2e(doc)

        # number of medication sections
        assert_equal 63, patient.medications.size
        medication = patient.medications[35]
        assert medication.codes['HC-DIN'].include? '02256134'
        assert medication.codes['whoATC'].include? 'C07AB07'
        assert_equal "APO-BISOPROLOL 5MG", medication.description

        assert_equal "5.0", medication.values.first.scalar
        assert_equal "tab", medication.values.first.units

        assert_equal Time.gm(2015,3,9).to_i, medication.time
        assert_equal Time.gm(2015,3,9).to_i, medication.start_time
        assert_equal Time.gm(2015,6,17).to_i, medication.end_time

        assert_equal 1, medication.administration_timing['frequency']['numerator']['value']
        assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
        assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

        assert_equal TRUE, medication.longTerm
        assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig

        ### TODO Find out why medication.dose isn't working!!!
        #assert_equal '1.0', medication.inspect # dose['low']
        #assert_equal '1.0', medication.dose['high']

        assert_equal 'active', medication.statusOfMedication[:value]

        assert_equal 'PO', medication.route['code']
        assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
        assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
        assert_equal 'PO', medication.route['displayName']

        assert_equal nil, medication.product_form['code']

        assert_equal 32, medication.order_information.size
        #### TODO Enhance parsing of order_information
        #assert_equal 1, medication.order_information.first.fills
        #assert_equal 1, medication.order_information.first.quantity_ordered['value']
        #assert_equal 'tablet', medication.order_information.first.quantity_ordered['unit']
        assert_equal '', medication.order_information[0].performer.given_name
        assert_equal 'kxDpGMv+o1ZFJEXV/9LUTW1tA7uVv3c/fhT13Q==', medication.order_information[0].performer.family_name
        #assert_equal Time.gm(2014,6,25).to_i, medication.order_information[0].performer.start
        assert_equal medication.order_information[0].performer.start, medication.order_information[0].orderDateTime
        assert_equal '', medication.order_information[0].performer.npi
        assert_equal FALSE, medication.order_information[0].prn
        assert_equal TRUE, medication.order_information[10].prn
        assert_equal FALSE, medication.order_information[31].prn

        medication = patient.medications[34]
        assert_equal 'APO-RAMIPRIL 5MG', medication.description
        assert_equal 11, medication.order_information.size
        assert_equal TRUE, medication.longTerm
        assert_equal ' E2E_LONG_TERM_FLAG', medication.freeTextSig
        refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
        assert_equal Time.gm(2013,2,27).to_i, medication.order_information[0].orderDateTime
        assert_equal Time.gm(2013,5,28).to_i, medication.order_information[0].orderExpirationDateTime
        assert_equal FALSE, medication.order_information[0].prn
        assert_equal Time.gm(2012,12,10).to_i, medication.order_information[1].orderDateTime
        assert_equal Time.gm(2013,3,10).to_i, medication.order_information[1].orderExpirationDateTime
        assert_equal FALSE, medication.order_information[1].prn
        assert_equal Time.gm(2012,9,17).to_i, medication.order_information[2].orderDateTime
        assert_equal Time.gm(2012,12,16).to_i, medication.order_information[2].orderExpirationDateTime
        assert_equal TRUE, medication.order_information[2].prn
        assert_equal Time.gm(2010,12,1).to_i, medication.order_information[10].orderDateTime
        assert_equal Time.gm(2011,3,1).to_i, medication.order_information[10].orderExpirationDateTime
        assert_equal FALSE, medication.order_information[10].prn
        assert_equal 'kxDpGMv+o1ZFJEXV/9LUTW1tA7uVv3c/fhT13Q==', medication.order_information[0].performer.family_name
        assert_equal 'kxDpGMv+o1ZFJEXV/9LUTW1tA7uVv3c/fhT13Q==', medication.order_information[10].performer.family_name
    end
=end

    def test_medication_importing_complete_example
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      patient.save!

      # number of medication sections
      assert_equal 1, patient.medications.size

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
      assert_equal 4, medication.administration_timing['period']['low']['value']
      assert_equal 'h', medication.administration_timing['period']['low']['unit']
      assert_equal 6, medication.administration_timing['period']['high']['value']
      assert_equal 'h', medication.administration_timing['period']['high']['unit']
      assert_equal 10, medication.administration_timing['duration']['width']['value']
      assert_equal 'D', medication.administration_timing['duration']['width']['unit']

      #TODO - fix freeTextSig
      assert_equal FALSE, medication.longTerm
      prntrue = 'E2E_PRN_FLAG'
      assert medication.freeTextSig.include? prntrue
      text1 = "One spray every 5 minutes as needed for chest discomfort."
      assert medication.freeTextSig.include? text1
      text2 = "If pain continues for more than 15 minutes or recurs frequently, get to emergency department ASAP."
      assert medication.freeTextSig.include? text2

      #assert_equal '325', medication.dose['low']
      #assert_equal '650', medication.dose['high']
      assert_equal nil, medication.dose

      assert_equal 'active', medication.statusOfMedication[:value]

      assert_equal 'PO', medication.route['code']
      assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
      assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
      assert_equal 'per os', medication.route['displayName']

      assert_equal 'ORSPRAY', medication.product_form['code']
      assert_equal '2.16.840.1.113883.1.11.14570', medication.product_form['codeSystem']
      assert_equal 'oral spray', medication.product_form['displayName']

      assert_equal 1, medication.order_information.size
      assert_equal '', medication.order_information[0].performer.given_name
      assert_equal 'vdX7pCevIhQh7oEafJD6xtu5SVQxXwwc85znuA==', medication.order_information[0].performer.family_name
      assert_equal Time.gm(2013,2,11).to_i, medication.order_information[0].orderDateTime
      assert_equal Time.gm(2013,2,12).to_i, medication.order_information[0].orderExpirationDateTime
      assert_equal Time.gm(2003,5,29).to_i, medication.order_information[0].performer.start
      assert_equal '', medication.order_information[0].performer.npi
      assert_equal TRUE, medication.order_information[0].prn

    end

    def test_medication_importing_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      # number of medication sections
      assert_equal 7, patient.medications.size

      # no useful provider information for Zarilla
      patient.medications.each do |medication|
        assert_equal 1, medication.order_information.size
        assert_equal '', medication.order_information[0].performer.given_name
        assert_equal '0UoCjCo6K8lHYQK7KII0xBWisB+CjqYqxbPkLw==', medication.order_information[0].performer.family_name
        assert_equal nil, medication.order_information[0].performer.start
        #assert_equal Time.gm(2014,2,27).to_i, medication.order_information[0].orderDateTime
        #assert_equal Time.gm(2014,3,6).to_i, medication.order_information[0].orderExpirationDateTime
        assert_equal '', medication.order_information[0].performer.npi
      end

      # first listed medication
      medication = patient.medications[0]
      assert_equal "VENTOLIN HFA", medication.description
      assert medication.codes['HC-DIN'].include? '2241497'
      #assert_equal "xyz", medication.codes.inspect
      assert medication.codes['whoATC'].include? 'R03AC02'

      assert_equal "100", medication.values.first.scalar
      assert_equal "Mcg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2013,11,6).to_i, medication.start_time
      assert_equal Time.gm(2013,11,6).to_i, medication.order_information[0].orderDateTime
      #assert_equal Time.gm(2014,3,6).to_i, medication.order_information[0].orderExpirationDateTime
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal nil, medication.longTerm
      assert_equal '1-2 Puffs four times daily for 30 days. Use with Aerochamber', medication.freeTextSig
      assert_equal '[Frequency: Four times daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
      assert_equal 1, medication.order_information.size
      assert_equal FALSE, medication.order_information[0].prn

      # second listed medication
      medication = patient.medications[1]
      assert_equal "ERYTHRO-BASE", medication.description
      assert medication.codes['HC-DIN'].include? '682020'
      assert medication.codes['whoATC'].include? 'J01FA01'

      assert_equal "1", medication.values.first.scalar
      assert_equal "Tablet(s)", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,2,13).to_i, medication.start_time
      assert_equal Time.gm(2014,2,13).to_i, medication.order_information[0].orderDateTime
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal nil, medication.longTerm
      assert_equal 'Take with Food', medication.freeTextSig
      assert_equal '[Frequency: Four times daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
      assert_equal 1, medication.order_information.size
      assert_equal FALSE, medication.order_information[0].prn

      # third listed medication (Note: has PRNIND set to true)
      medication = patient.medications[2]
      assert_equal "Melatonin 5mg capsule", medication.description
      assert medication.codes['Unknown'].include? 'NI'

      assert_equal "5", medication.values.first.scalar
      assert_equal "Mg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,2,4).to_i, medication.start_time
      assert_equal Time.gm(2014,2,4).to_i, medication.order_information[0].orderDateTime
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal nil, medication.longTerm
      assert_equal 'One capsule daily at bedtime as needed
. Take at bedtime E2E_PRN_FLAG', medication.freeTextSig
      assert_equal '[Frequency: Once daily]', medication.administration_timing['text']
      assert_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
      assert_equal 1, medication.order_information.size
      assert_equal TRUE, medication.order_information[0].prn

      # fourth listed medication
      medication = patient.medications[3]
      assert_equal "AMOXICILLIN 125MG/5ML SUSP", medication.description
      assert medication.codes['HC-DIN'].include? '2243224'
      assert medication.codes['whoATC'].include? 'Unknown'

      assert_equal "125", medication.values.first.scalar
      assert_equal "Mg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,2,27).to_i, medication.start_time
      assert_equal Time.gm(2014,3,6).to_i, medication.end_time
      assert_equal Time.gm(2014,2,27).to_i, medication.order_information[0].orderDateTime
      assert_equal Time.gm(2014,3,6).to_i, medication.order_information[0].orderExpirationDateTime
      assert_equal 'completed', medication.statusOfMedication[:value]
      assert_equal nil, medication.longTerm
      assert_equal '125mg (5ml) three times daily
. Shake well before use and take until finished', medication.freeTextSig
      assert_equal '[Frequency: Three times daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
      assert_equal 1, medication.order_information.size
      assert_equal FALSE, medication.order_information[0].prn

      # fifth listed medication
      medication = patient.medications[4]
      assert_equal "DOM-SALBUTAMOL 5MG/ML SOLN", medication.description
      assert medication.codes['HC-DIN'].include? '2139324'
      assert medication.codes['whoATC'].include? 'Unknown'

      assert_equal "1", medication.values.first.scalar
      assert_equal "Millilitres", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,1,5).to_i, medication.start_time
      assert_equal Time.gm(2014,1,5).to_i, medication.order_information[0].orderDateTime
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal nil, medication.longTerm
      assert_equal '1ml with 5ml Normal saline by Nebulizer twice daily.', medication.freeTextSig
      assert_equal '[Frequency: Twice daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
      assert_equal 1, medication.order_information.size
      assert_equal FALSE, medication.order_information[0].prn

      # sixth listed medication
      medication = patient.medications[5]
      assert_equal "KENALOG-10 INJECTION 10MG/ML", medication.description
      assert medication.codes['HC-DIN'].include? '1999761'
      assert medication.codes['whoATC'].include? 'H02AB08'

      assert_equal "5", medication.values.first.scalar
      assert_equal "Mg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,2,4).to_i, medication.start_time
      assert_equal Time.gm(2014,2,4).to_i, medication.order_information[0].orderDateTime
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal nil, medication.longTerm
      assert_equal '5mg administered intra-articularly to right foot monthly. Bring medication to Doctor\'s office for administration.', medication.freeTextSig
      assert_equal '[Frequency: Once a month]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['code']
      assert_equal 'intra-articularly', medication.route['text']
      assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
      assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
      assert_equal 1, medication.order_information.size
      assert_equal FALSE, medication.order_information[0].prn

      # seventh and last listed medication
      medication = patient.medications[6]
      assert_equal "APO-METHYLPHENIDATE", medication.description
      assert medication.codes['HC-DIN'].include? '2273950'
      assert medication.codes['whoATC'].include? 'N06BA04'

      assert_equal "5", medication.values.first.scalar
      assert_equal "Mg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2013,12,6).to_i, medication.start_time
      assert_equal Time.gm(2014,3,6).to_i, medication.end_time
      assert_equal Time.gm(2013,12,6).to_i, medication.order_information[0].orderDateTime
      assert_equal Time.gm(2014,3,6).to_i, medication.order_information[0].orderExpirationDateTime
      assert_equal 'completed', medication.statusOfMedication[:value]
      assert_equal nil, medication.longTerm
      assert_equal '5mg twice daily.', medication.freeTextSig
      assert_equal '[Frequency: Twice daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
      assert_equal 1, medication.order_information.size
      assert_equal FALSE, medication.order_information[0].prn


    end

    def test_medication_importing_zarilla2
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla2.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      #puts YAML::dump(patient.medications)

      # number of medication sections
      assert_equal 6, patient.medications.size

      # no useful provider information for Zarilla
      patient.medications.each do |medication|
        assert_equal 1, medication.order_information.size
        assert_equal '', medication.order_information[0].performer.given_name
        assert_equal '0UoCjCo6K8lHYQK7KII0xBWisB+CjqYqxbPkLw==', medication.order_information[0].performer.family_name
        assert_equal nil, medication.order_information[0].performer.start
        assert_equal '', medication.order_information[0].performer.npi
      end

      # first listed medication
      medication = patient.medications[0]
      assert_equal "VENTOLIN HFA", medication.description
      assert medication.codes['HC-DIN'].include? '2241497'

      assert_equal "100", medication.values.first.scalar
      assert_equal "Mcg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal -2208985139, medication.start_time
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal '1-2 Puffs four times daily for 30 days. Use with Aerochamber', medication.freeTextSig
      assert_equal '[Frequency: Four times daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size

      # second listed medication
      medication = patient.medications[1]
      assert_equal "ERYTHRO-BASE", medication.description
      assert medication.codes['HC-DIN'].include? '682020'

      assert_equal "1", medication.values.first.scalar
      assert_equal "Tablet(s)", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,2,13).to_i, medication.start_time
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal 'Take with Food', medication.freeTextSig
      assert_equal '[Frequency: Four times daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size

      # fourth listed medication
      medication = patient.medications[2]
      assert_equal "AMOXICILLIN 125MG/5ML SUSP", medication.description
      assert medication.codes['HC-DIN'].include? '2243224'

      assert_equal "125", medication.values.first.scalar
      assert_equal "Mg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,2,27).to_i, medication.start_time
      assert_equal Time.gm(2014,3,6).to_i, medication.end_time
      assert_equal 'completed', medication.statusOfMedication[:value]
      assert_equal '125mg (5ml) three times daily
. Shake well before use and take until finished', medication.freeTextSig
      assert_equal '[Frequency: Three times daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size

      # fifth listed medication
      medication = patient.medications[3]
      assert_equal "DOM-SALBUTAMOL 5MG/ML SOLN", medication.description
      assert medication.codes['HC-DIN'].include? '2139324'

      assert_equal "1", medication.values.first.scalar
      assert_equal "Millilitres", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,1,5).to_i, medication.start_time
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal '1ml with 5ml Normal saline by Nebulizer twice daily.', medication.freeTextSig
      assert_equal '[Frequency: Twice daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size

      # sixth listed medication
      medication = patient.medications[4]
      assert_equal "KENALOG-10 INJECTION 10MG/ML", medication.description
      assert medication.codes['HC-DIN'].include? '1999761'

      assert_equal "5", medication.values.first.scalar
      assert_equal "Mg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2014,2,4).to_i, medication.start_time
      assert_equal 'active', medication.statusOfMedication[:value]
      assert_equal '5mg administered intra-articularly to right foot monthly. Bring medication to Doctor\'s office for administration.', medication.freeTextSig
      assert_equal '[Frequency: Once a month]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['code']
      assert_equal 'intra-articularly', medication.route['text']
      assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
      assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size

      # seventh and last listed medication
      medication = patient.medications[5]
      assert_equal "APO-METHYLPHENIDATE", medication.description
      assert medication.codes['HC-DIN'].include? '2273950'

      assert_equal "5", medication.values.first.scalar
      assert_equal "Mg", medication.values.first.units
      assert_equal nil, medication.dose
      assert_equal Time.gm(2013,12,6).to_i, medication.start_time
      assert_equal Time.gm(2014,3,6).to_i, medication.end_time
      assert_equal 'completed', medication.statusOfMedication[:value]
      assert_equal '5mg twice daily.', medication.freeTextSig
      assert_equal '[Frequency: Twice daily]', medication.administration_timing['text']
      refute_includes medication.freeTextSig, 'E2E_PRN_FLAG'
      assert_nil medication.route['text']
      assert_nil medication.route['code']
      assert_nil medication.route['codeSystem']
      assert_nil medication.route['codeSystemName']
      assert_nil medication.route['displayName']
      assert_equal 0, medication.product_form.size
    end

  end
end
