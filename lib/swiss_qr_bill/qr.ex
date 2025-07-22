defmodule SwissQRBill.QR do
  @address_schema [
    name: [type: :string],
    street: [type: :string],
    building_number: [type: :string],
    city: [type: :string, required: true],
    zip_code: [type: :string, required: true],
    country: [type: :string, required: true]
  ]

  @options_schema NimbleOptions.new!(
                    iban: [required: true, type: :string],
                    creditor: [
                      type: {:or, [:keyword_list, :map]},
                      required: true,
                      keys: @address_schema,
                      doc: "Creditor information"
                    ],
                    amount: [type: :float],
                    currency: [
                      type: :string,
                      default: "CHF",
                      doc: "Only supported currency are `CHF` and `EUR`."
                    ],
                    debtor: [
                      type: {:or, [:keyword_list, :map]},
                      keys: @address_schema,
                      doc: "Debtor information"
                    ],
                    reference_type: [
                      type: {:in, [:non, :qrr, :scor]},
                      default: :non,
                      doc: "Only supported reference types are `:non`, `:qrr` and `:scor`."
                    ],
                    reference: [
                      type: :string,
                      doc: "Reference number. Only supported for :reference_type SCOR and QRR"
                    ],
                    additional_info: [
                      type: :string,
                      doc: "Additional information"
                    ]
                  )

  @type options() :: [unquote(NimbleOptions.option_typespec(@options_schema))]

  @doc """
  Supported options:
  #{NimbleOptions.docs(@options_schema)}
  """
  @spec generate_qr_code(options()) :: String.t()
  def generate_qr_code(opts) do
    opts
    |> NimbleOptions.validate!(@options_schema)
    |> generate_qr_code_svg()
  end

  defp generate_qr_code_svg(data) do
    with {:ok, payload} <- build_payload(data) do
      svg_settings = %QRCode.Render.SvgSettings{
        image: {"priv/swiss_qr_bill/assets/CH-Kreuz_7mm.svg", 70}
        # structure: :minify
      }

      payload
      |> QRCode.create(:medium)
      |> QRCode.render(:svg, svg_settings)
    end
  end

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

    {:ok, payload}
  end

  defp format_address(address) when is_map(address) do
    [
      "S",
      address[:name],
      address[:street],
      address[:building_number],
      address[:zip_code],
      address[:city],
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

  defp format_amount(_), do: ""

  defp format_reference_type(:qrr), do: "QRR"
  defp format_reference_type(:scor), do: "SCOR"
  defp format_reference_type(:non), do: "NON"
end
