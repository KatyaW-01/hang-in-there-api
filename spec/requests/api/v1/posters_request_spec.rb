require 'rails_helper'

describe "Posters API", type: :request do
  it "sends a list of posters" do
    Poster.create(name: "FAILURE",
    description: "Why bother trying? It's probably not worth it.",
    price: 68.00,
    year: 2019,
    vintage: true,
    img_url: "./assets/failure.jpg")

    Poster.create(name: "MEDIOCRITY",
    description: "Dreams are just that—dreams.",
    price: 127.00,
    year: 2021,
    vintage: false,
    img_url: "./assets/mediocrity.jpg")

    Poster.create(name: "REGRET",
    description: "Hard work rarely pays off.",
    price: 89.00,
    year: 2018,
    vintage: true,
    img_url:  "./assets/regret.jpg")

    get "/api/v1/posters"

    expect(response).to be_successful
    
    posters = JSON.parse(response.body, symbolize_names: true)

    expect(posters).to have_key(:data)
    expect(posters[:data]).to be_an(Array)
    expect(posters[:data].count).to eq(3)

    posters[:data].each do |poster|
      expect(poster).to have_key(:id)
      expect(poster[:id]).to be_an(String)
      expect(poster).to have_key(:type)
      expect(poster[:type]).to be_a(String)
      expect(poster).to have_key(:attributes)

      attributes = poster[:attributes]

      expect(attributes).to have_key(:description)
      expect(attributes[:description]).to be_a(String)

      expect(attributes).to have_key(:price)
      expect(attributes[:price]).to be_a(Float)

      expect(attributes).to have_key(:year)
      expect(attributes[:year]).to be_an(Integer)

      expect(attributes).to have_key(:vintage)
      expect(attributes[:vintage]).to be_in([true, false])

      expect(attributes).to have_key(:img_url)
      expect(attributes[:img_url]).to be_a(String) 
    end
  end

  it "sends one poster" do
    poster = Poster.create(
      name: "REGRET",
      description: "Hard work rarely pays off.",
      price: 89.00,
      year: 2018,
      vintage: true,
      img_url: "./assets/regret.jpg"
    )
  
    get "/api/v1/posters/#{poster.id}"
  
    expect(response).to be_successful
  
    poster_response = JSON.parse(response.body, symbolize_names: true)
  
    data = poster_response[:data]
    attributes = data[:attributes]
  
    expect(data[:id]).to eq(poster.id.to_s)
    expect(data[:type]).to eq("poster")
    expect(attributes[:name]).to eq("REGRET")
    expect(attributes[:description]).to eq("Hard work rarely pays off.")
    expect(attributes[:price]).to eq(89.00)
    expect(attributes[:year]).to eq(2018)
    expect(attributes[:vintage]).to eq(true)
    expect(attributes[:img_url]).to eq("./assets/regret.jpg")
  end
end

  it 'can create a new poster' do
    poster_params = {
                        name: "HOPELESSNESS",
                        description: "Stay in your comfort zone; it's safer.",
                        price: 112.00,
                        year: 2020,
                        vintage: true,
                        img_url: "./assets/hopelessness.jpg"
    }
    headers = { "CONTENT_TYPE" => "application/json"}

    post "/api/v1/posters", headers: headers, params: JSON.generate(poster: poster_params)
    created_poster = Poster.last

    expect(response).to be_successful
    expect(created_poster.name).to eq(poster_params[:name])
    expect(created_poster.description).to eq(poster_params[:description])
    expect(created_poster.price).to eq(poster_params[:price])
    expect(created_poster.year).to eq(poster_params[:year])
    expect(created_poster.vintage).to eq(poster_params[:vintage])
    expect(created_poster.img_url).to eq(poster_params[:img_url])
  end
end
























  it 'can destroy a poster' do
    poster = Poster.create(name: "HOPELESSNESS",
    description: "Stay in your comfort zone; it's safer.",
    price: 112.00,
    year: 2020,
    vintage: true,
    img_url: "./assets/hopelessness.jpg")

    expect(Poster.count).to eq(1)

    delete "/api/v1/posters/#{poster.id}"

    expect(response).to be_successful
    expect(Poster.count).to eq(0)

    expect{Poster.find(poster.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

