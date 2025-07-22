defmodule SwissQRBill do
  @moduledoc """
  Documentation for `SwissQRBill`.
  """

  defdelegate generate(data), to: SwissQRBill.QR, as: :generate_qr_code
end
