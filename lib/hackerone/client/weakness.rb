# frozen_string_literal: true

module HackerOne
  module Client
    class Weakness
      class << self
        def validate_cwe!(cwe)
          fail NotAnOwaspWeaknessError if cwe.upcase.start_with?("CAPEC-")
          fail StandardError::ArgumentError unless cwe.upcase.start_with?("CWE-")
        end

        def extract_cwe_number(cwe)
          return if cwe.nil?
          validate_cwe!(cwe)

          cwe.split("CWE-").last.to_i
        end
      end

      class NotAnOwaspWeaknessError < StandardError
        def message
          "CAPEC labels do not describe OWASP weaknesses"
        end
      end

      CLASSIFICATION_MAPPING = {
        "None Applicable" => "A0-Other",
        "Denial of Service" => "A0-Other",
        "Memory Corruption" => "A0-Other",
        "Cryptographic Issue" => "A0-Other",
        "Privilege Escalation" => "A0-Other",
        "UI Redressing (Clickjacking)" => "A0-Other",
        "Command Injection" => "A1-Injection",
        "Remote Code Execution" => "A1-Injection",
        "SQL Injection" => "A1-Injection",
        "Authentication" => "A2-AuthSession",
        "Cross-Site Scripting (XSS)" => "A3-XSS",
        "Information Disclosure" => "A6-DataExposure",
        "Cross-Site Request Forgery (CSRF)" => "A8-CSRF",
        "Unvalidated / Open Redirect" => "A10-Redirects"
      }

      OWASP_TOP_10_2013_TO_CWE = {
        "A1-Injection" => [77, 78, 88, 89, 90, 91, 564],
        "A2-AuthSession" =>
          [287, 613, 522, 256, 384, 472, 346, 441, 523, 620, 640, 319, 311],
        "A3-XSS" => [79],
        "A4-DirectObjRef" => [639, 99, 22],
        "A5-Misconfig" => [16, 2, 215, 548, 209],
        "A6-DataExposure" => [312, 319, 310, 326, 320, 311, 325, 328, 327],
        "A7-MissingACL" => [285, 287],
        "A8-CSRF" => [352, 642, 613, 346, 441],
        "A9-KnownVuln" => [],
        "A10-Redirects" => [601],
      }.freeze

      OWASP_DEFAULT = "A0-Other".freeze

      def initialize(weakness)
        @attributes = weakness
      end

      def to_owasp
        from_cwe = OWASP_TOP_10_2013_TO_CWE.map do |owasp, cwes|
          owasp if cwes.include?(self.class.extract_cwe_number(to_cwe))
        end.compact.first

        from_cwe || CLASSIFICATION_MAPPING[@attributes[:name]] || OWASP_DEFAULT
      end

      def to_cwe
        @attributes[:external_id]
      end
    end
  end
end
