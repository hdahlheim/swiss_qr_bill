defmodule SwissQRBill.QR do
  alias SwissQRBill.SPS_2_3, as: Spec

  @address_schema [
    name: [type: :string],
    street: [type: :string],
    building_number: [type: :string],
    town: [type: :string, required: true],
    postal_code: [type: :string, required: true],
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
    with {:ok, payload} <- Spec.build_payload(data) do
      svg_settings = %QRCode.Render.SvgSettings{
        image: {"priv/swiss_qr_bill/assets/CH-Kreuz_7mm.svg", 70},
        structure: :minify
      }

      payload
      |> QRCode.create(:medium)
      |> QRCode.render(:svg, svg_settings)
    end
  end
end
