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
    
    expect(posters).to have_key(:meta)
    expect(posters[:meta]).to be_an(Hash)
    expect(posters[:meta][:count]).to eq(3)

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

  it 'can update a poster' do
    posterId = Poster.create( 
    name: "FAILURE",
    description: "Why bother trying? It's probably not worth it.",
    price: 68.0,
    year: 2019,
    vintage: true,
    img_url: "./assets/failure.jpg").id

    previous_name = Poster.last.name
    poster_params = {name: "CRY"}
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/posters/#{posterId}", headers: headers, params: JSON.generate({poster: poster_params})

    poster = Poster.find_by(id: posterId)
    expect(response).to be_successful
    expect(poster.name).to_not eq(previous_name)
    expect(poster.name).to eq("CRY")
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

  it "filteres according to user input #name" do
    poster = Poster.create(
      name: "REGRET",
      description: "Hard work rarely pays off.",
      price: 89.00,
      year: 2018,
      vintage: true,
      img_url: "./assets/regret.jpg")
  
      poster = Poster.create(
      name: "MEDIOCRITY",
      description: "Dreams are just that—dreams.",
      price: 127.00,
      year: 2021,
      vintage: false,
      img_url: "./assets/mediocrity.jpg")
    
     get "/api/v1/posters?name=ret"
  
    expect(response).to be_successful
    
    posters = JSON.parse(response.body, symbolize_names: true)
    
    expect(posters).to have_key(:data)
    expect(posters[:data]).to be_an(Array)
    expect(posters[:data].count).to eq(1)
    data = posters[:data]
    attributes = data[0][:attributes]
    expect(attributes[:name]).to eq("REGRET")
    expect(attributes[:description]).to eq("Hard work rarely pays off.")
    expect(attributes[:price]).to eq(89.00)
    expect(attributes[:year]).to eq(2018)
    expect(attributes[:vintage]).to eq(true)
    expect(attributes[:img_url]).to eq("./assets/regret.jpg")
  end

  it "filteres according to min_price" do
    poster = Poster.create(
      name: "REGRET",
      description: "Hard work rarely pays off.",
      price: 89.00,
      year: 2018,
      vintage: true,
      img_url: "./assets/regret.jpg"
    )
    poster =  Poster.create(
      name: "MEDIOCRITY",
      description: "Dreams are just that—dreams.",
      price: 127.00,
      year: 2021,
      vintage: false,
      img_url: "./assets/mediocrity.jpg")

    poster = Poster.create(
      name: "FAILURE",
      description: "Why bother trying? It's probably not worth it.",
      price: 68.00,
      year: 2019,
      vintage: true,
      img_url: "./assets/failure.jpg")


     get "/api/v1/posters?min_price=88"
  
    expect(response).to be_successful
  
    posters = JSON.parse(response.body, symbolize_names: true)
    expect(posters).to have_key(:data)
    expect(posters[:data]).to be_an(Array)
    expect(posters[:data].count).to eq(2)

    data = posters[:data]
    attributes1 = data[0][:attributes]
    expect(attributes1[:name]).to eq("REGRET")
    expect(attributes1[:description]).to eq("Hard work rarely pays off.")
    expect(attributes1[:price]).to eq(89.00)
    expect(attributes1[:year]).to eq(2018)
    expect(attributes1[:vintage]).to eq(true)
    expect(attributes1[:img_url]).to eq("./assets/regret.jpg")

    attributes2 = data[1][:attributes]
    expect(attributes2[:name]).to eq("MEDIOCRITY")
    expect(attributes2[:description]).to eq("Dreams are just that—dreams.")
    expect(attributes2[:price]).to eq(127.00)
    expect(attributes2[:year]).to eq(2021)
    expect(attributes2[:vintage]).to eq(false)
    expect(attributes2[:img_url]).to eq("./assets/mediocrity.jpg")
  end

  it "filteres according to max_price" do
    poster = Poster.create(
      name: "MEDIOCRITY",
      description: "Dreams are just that—dreams.",
      price: 127.00,
      year: 2021,
      vintage: false,
      img_url: "./assets/mediocrity.jpg")

    poster = Poster.create(
      name: "REGRET",
      description: "Hard work rarely pays off.",
      price: 89.00,
      year: 2018,
      vintage: true,
      img_url:  "./assets/regret.jpg")

    poster = Poster.create(
      name: "FAILURE",
      description: "Why bother trying? It's probably not worth it.",
      price: 68.00,
      year: 2019,
      vintage: true,
      img_url: "./assets/failure.jpg")

  
     get "/api/v1/posters?max_price=88"
  
    expect(response).to be_successful
  
    posters = JSON.parse(response.body, symbolize_names: true)

    expect(posters).to have_key(:data)
    expect(posters[:data]).to be_an(Array)
    expect(posters[:data].count).to eq(1)
    data = posters[:data]
    attributes = data[0][:attributes]
    expect(attributes[:name]).to eq("FAILURE")
    expect(attributes[:description]).to eq("Why bother trying? It's probably not worth it.")
    expect(attributes[:price]).to eq(68.00)
    expect(attributes[:year]).to eq(2019)
    expect(attributes[:vintage]).to eq(true)
    expect(attributes[:img_url]).to eq("./assets/failure.jpg")
  end

  it 'can sort by ascending order' do
    poster = Poster.create(
      name: "MEDIOCRITY",
      description: "Dreams are just that—dreams.",
      price: 127.00,
      year: 2021,
      vintage: false,
      img_url: "./assets/mediocrity.jpg",
      created_at: "2025-04-08 19:40:19.538863")

    poster = Poster.create(
      name: "REGRET",
      description: "Hard work rarely pays off.",
      price: 89.00,
      year: 2018,
      vintage: true,
      img_url:  "./assets/regret.jpg",
      created_at: "2025-04-08 19:40:19.540318")

    poster = Poster.create(
      name: "FAILURE",
      description: "Why bother trying? It's probably not worth it.",
      price: 68.00,
      year: 2019,
      vintage: true,
      img_url: "./assets/failure.jpg",
      created_at: "2025-04-08 19:40:19.535758")

    get "/api/v1/posters?sort=asc"

    expect(response).to be_successful
  
    posters = JSON.parse(response.body, symbolize_names: true)

    expect(posters).to have_key(:data)
    expect(posters[:data]).to be_an(Array)
    
    expect(posters).to have_key(:meta)
    expect(posters[:meta]).to be_an(Hash)
    expect(posters[:meta][:count]).to eq(3)

    data = posters[:data]
    attributes1 = data[0][:attributes]
    attributes2 = data[1][:attributes]
    attributes3 = data[2][:attributes]

    expect(attributes1[:name]).to eq("FAILURE")
    expect(attributes2[:name]).to eq("MEDIOCRITY")
    expect(attributes3[:name]).to eq("REGRET")
  end
  
  it 'can sort by descending order' do
    poster = Poster.create(
      name: "MEDIOCRITY",
      description: "Dreams are just that—dreams.",
      price: 127.00,
      year: 2021,
      vintage: false,
      img_url: "./assets/mediocrity.jpg",
      created_at: "2025-04-08 19:40:19.538863")

    poster = Poster.create(
      name: "REGRET",
      description: "Hard work rarely pays off.",
      price: 89.00,
      year: 2018,
      vintage: true,
      img_url:  "./assets/regret.jpg",
      created_at: "2025-04-08 19:40:19.540318")

    poster = Poster.create(
      name: "FAILURE",
      description: "Why bother trying? It's probably not worth it.",
      price: 68.00,
      year: 2019,
      vintage: true,
      img_url: "./assets/failure.jpg",
      created_at: "2025-04-08 19:40:19.535758")

    get "/api/v1/posters?sort=desc"

    expect(response).to be_successful
  
    posters = JSON.parse(response.body, symbolize_names: true)

    expect(posters).to have_key(:data)
    expect(posters[:data]).to be_an(Array)
    
    expect(posters).to have_key(:meta)
    expect(posters[:meta]).to be_an(Hash)
    expect(posters[:meta][:count]).to eq(3)

    data = posters[:data]
    attributes1 = data[0][:attributes]
    attributes2 = data[1][:attributes]
    attributes3 = data[2][:attributes]

    expect(attributes1[:name]).to eq("REGRET")
    expect(attributes2[:name]).to eq("MEDIOCRITY")
    expect(attributes3[:name]).to eq("FAILURE")
  end
end

