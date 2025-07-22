defmodule SwissQRBill.SPS_2_3Test do
  use ExUnit.Case
  doctest SwissQRBill.SPS_2_3

  alias SwissQRBill.SPS_2_3

  test "validate data with structured address payload" do
    data = File.read!("priv/swiss_qr_bill/datenschema/Nr. 1 Datenschema englisch.txt")

    {:ok, payload} =
      SPS_2_3.build_payload(%{
        iban: "CH6431961000004421557",
        creditor: %{
          name: "Health insurance fit&kicking",
          street: "Am Wasser",
          building_number: "1",
          postal_code: "3000",
          town: "Bern",
          country: "CH"
        },
        amount: 111.00,
        currency: "CHF",
        debtor: %{
          name: "Sarah Beispiel",
          street: "Mustergasse",
          building_number: "1",
          postal_code: "3600",
          town: "Thun",
          country: "CH"
        },
        reference_type: :qrr,
        reference: "000008207791225857421286694",
        additional_info: "Premium calculation July 2020"
      })

    assert data == payload
  end
end
