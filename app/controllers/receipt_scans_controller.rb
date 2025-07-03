class ReceiptScansController < ApplicationController
  before_action :authenticate_user!

  def new
    # Renders the upload form
  end

  def create
    uploaded_io = params[:image]
    unless uploaded_io&.content_type&.start_with?("image/")
      flash[:alert] = "Please upload a valid image file."
      return redirect_to new_receipt_scan_path
    end

    require "mini_magick"
    require "faraday"
    require "json"
    image = MiniMagick::Image.read(uploaded_io.read)
    image.auto_orient
    image.resize "1080x1080>"

    # Save to a temp file for OpenAI upload
    temp_path = Rails.root.join("tmp", "resized_#{SecureRandom.hex(8)}.jpg")
    image.write(temp_path)

    categories = ["Food", "Beverage", "Transport", "Shopping", "Entertainment", "Healthcare", "Utilities", "Housing", "Education", "Travel", "Other"]
    prompt = <<~PROMPT
      Extract all items (with name, price, and category), the date, and the total from this Japanese receipt image. Translate all fields to English. Map each item to one of these categories: #{categories}.
      Return only valid JSON, with no markdown, no code block, and no explanation.
    PROMPT

    # Prepare multipart request to OpenAI API
    begin
      conn = Faraday.new(url: "https://api.openai.com") do |f|
        f.adapter Faraday.default_adapter
      end
      payload = {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are a helpful assistant that extracts and translates Japanese receipts for an expense tracker app." },
          { role: "user", content: [
            { type: "text", text: prompt },
            { type: "image_url", image_url: { url: "data:image/jpeg;base64,#{Base64.strict_encode64(File.binread(temp_path))}" } }
          ] }
        ],
        max_tokens: 800
      }
      response = conn.post("/v1/chat/completions") do |req|
        req.headers["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
        req.headers["Content-Type"] = "application/json"
        req.body = payload.to_json
      end
      if response.status == 200
        raw_content = JSON.parse(response.body).dig("choices", 0, "message", "content")
        cleaned_content = raw_content.gsub(/\A```json\s*|\A```|```\s*\z|\z```/i, "").strip
        parsed = JSON.parse(cleaned_content)
        session[:receipt_items] = parsed["items"] || []
        session[:receipt_date] = parsed["date"]
        flash[:notice] = "Receipt parsed successfully! Select items to add as expenses."
        redirect_to select_items_receipt_scans_path
      else
        Rails.logger.error "OpenAI API error: #{response.status} #{response.body}"
        flash[:alert] = "Could not parse receipt. Please try again or enter manually."
        redirect_to new_receipt_scan_path
      end
    rescue JSON::ParserError, Faraday::Error => e
      Rails.logger.error "OpenAI parse error: #{e.message}"
      flash[:alert] = "Could not parse receipt. Please try again or enter manually."
      redirect_to new_receipt_scan_path
    ensure
      File.delete(temp_path) if temp_path && File.exist?(temp_path)
    end
  end

  def select_items
    @items = session[:receipt_items] || []
    @date = session[:receipt_date]
    if @items.empty?
      flash[:alert] = "No items found. Please try again."
      redirect_to new_receipt_scan_path
    end
  end

  def handle_selection
    selected_indices = params[:selected_items]&.map(&:to_i) || []
    all_items = session[:receipt_items] || []
    selected_items = selected_indices.map { |idx| all_items[idx] }.compact
    if selected_items.empty?
      flash[:alert] = "Please select at least one item."
      return redirect_to select_items_receipt_scans_path
    end
    # Store selected items in session for multi-expense creation
    session[:selected_receipt_items] = selected_items
    redirect_to new_multiple_expenses_path(from_receipt: true)
  end

  # To be implemented: select_items action and view
end
