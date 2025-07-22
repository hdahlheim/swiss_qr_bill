defmodule SwissQRBill.SPS_2_3 do
  @doc """
  Implements the Swiss QR bill SPS (Swiss Payment Standards) 2.3 specification.
  """

  def build_payload(data) do
    payload =
      [
        "SPC",
        "0200",
        "1",
        data[:iban],
        format_address(data[:creditor]),
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        format_amount(data[:amount]),
        data[:currency],
        format_address(data[:debtor]),
        format_reference_type(data[:reference_type] || :non),
        data[:reference],
        data[:additional_info],
        "EPD"
      ]
      |> Enum.join("\r\n")

    payload =
      if data[:alternative_procedures],
        do: Enum.join(data[:alternative_procedures], "\r\n"),
        else: payload

    {:ok, payload}
  end

  defp format_address(address) when is_list(address) or is_map(address) do
    # In version 2.3 of QR Bill specification only the structured address type `S` is supported.
    # Older specifications supported the type `K` where address line 1 (street) and 2 (building number)
    # could be combined into one line (address line 1).
    #
    # Version 2.3 of QR Bill specification allows the address line 1 and to to be combined in type `S`
    # but the address information has to be compleat when a payment is attempted.
    [
      "S",
      address[:name],
      address[:street],
      address[:building_number],
      address[:postal_code],
      address[:town],
      address[:country]
    ]
    |> Enum.join("\r\n")
  end

  defp format_address(_),
    do:
      [
        "",
        "",
        "",
        "",
        "",
        "",
        ""
      ]
      |> Enum.join("\r\n")

  defp format_amount(amount) when is_float(amount),
    do: :erlang.float_to_binary(amount, decimals: 2)

  defp format_amount(amount) when is_integer(amount),
    do: Integer.to_string(amount) <> ".00"

  defp format_amount(_), do: ""

  defp format_reference_type(:qrr), do: "QRR"
  defp format_reference_type(:scor), do: "SCOR"
  defp format_reference_type(:non), do: "NON"
end
