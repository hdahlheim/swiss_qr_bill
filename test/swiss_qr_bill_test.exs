defmodule SwissQRBillTest do
  use ExUnit.Case
  doctest SwissQRBill

  test "validate data payload" do
    data = File.read!("priv/swiss_qr_bill/datenschema/Nr. 1 Datenschema englisch.txt")

    {:ok, payload} =
      SwissQRBill.QR.build_payload(%{
        iban: "CH6431961000004421557",
        creditor: %{
          name: "Health insurance fit&kicking",
          street: "Am Wasser",
          building_number: "1",
          zip_code: "3000",
          city: "Bern",
          country: "CH"
        },
        amount: 111.00,
        currency: "CHF",
        debtor: %{
          name: "Sarah Beispiel",
          street: "Mustergasse",
          building_number: "1",
          zip_code: "3600",
          city: "Thun",
          country: "CH"
        },
        reference_type: :qrr,
        reference: "000008207791225857421286694",
        additional_info: "Premium calculation July 2020"
      })

    assert data == payload
  end
end
