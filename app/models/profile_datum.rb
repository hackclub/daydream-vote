class ProfileDatum < ApplicationRecord
  belongs_to :user
  
  encrypts :first_name
  encrypts :last_name
  encrypts :dob
  encrypts :address_line_1
  encrypts :address_line_2
  encrypts :address_city
  encrypts :address_state
  encrypts :address_zip_code
  encrypts :address_country
  
  enum :attending_event, { 
    "daydream-abu-dhabi" => 0,
    "daydream-abu-hamad" => 1,
    "daydream-abuoka" => 2,
    "daydream-addis-ababa" => 3,
    "daydream-adelaide" => 4,
    "daydream-agadir" => 5,
    "daydream-al-qurna" => 6,
    "daydream-alexandria" => 7,
    "daydream-andover" => 8,
    "daydream-atfih" => 9,
    "daydream-atlanta" => 10,
    "daydream-auckland" => 11,
    "daydream-aurora" => 12,
    "daydream-austin" => 13,
    "daydream-barranquilla" => 14,
    "daydream-bengaluru" => 15,
    "daydream-bhagalpur" => 16,
    "daydream-biratnagar" => 17,
    "daydream-bogota" => 18,
    "daydream-boston" => 19,
    "daydream-braov" => 20,
    "daydream-brighton" => 21,
    "daydream-brisbane" => 22,
    "daydream-budapest" => 23,
    "daydream-bujumbura" => 24,
    "daydream-burlington" => 25,
    "daydream-butwal" => 26,
    "daydream-cairo" => 27,
    "daydream-calgary" => 28,
    "daydream-cambridge" => 29,
    "daydream-casablanca" => 30,
    "daydream-charlotte" => 31,
    "daydream-chitungwiza" => 32,
    "daydream-columbus" => 33,
    "daydream-dc" => 34,
    "daydream-dej" => 35,
    "daydream-delhi" => 36,
    "daydream-dfw" => 37,
    "daydream-diyarbakr" => 38,
    "daydream-durham" => 39,
    "daydream-folsom" => 40,
    "daydream-gahanga" => 41,
    "daydream-giza" => 42,
    "daydream-hamilton" => 43,
    "daydream-hanoi" => 44,
    "daydream-heist-op-den-berg" => 45,
    "daydream-helsinki" => 46,
    "daydream-hyderabad" => 47,
    "daydream-inland-empire" => 48,
    "daydream-islamabad" => 49,
    "daydream-istanbul" => 50,
    "daydream-jakarta" => 51,
    "daydream-jhansi" => 52,
    "daydream-karachi" => 53,
    "daydream-kathmandu" => 54,
    "daydream-kerala" => 55,
    "daydream-khagaria" => 56,
    "daydream-khobar" => 57,
    "daydream-kigali" => 58,
    "daydream-kl" => 59,
    "daydream-lagos" => 60,
    "daydream-lahore" => 61,
    "daydream-leosia" => 62,
    "daydream-lima" => 63,
    "daydream-london" => 64,
    "daydream-manchester" => 65,
    "daydream-miami" => 66,
    "daydream-missouri" => 67,
    "daydream-monterey" => 68,
    "daydream-monterrey" => 69,
    "daydream-mumbai" => 70,
    "daydream-muzaffarpur" => 71,
    "daydream-nanjing" => 72,
    "daydream-nj" => 73,
    "daydream-northfield" => 74,
    "daydream-novi" => 75,
    "daydream-nyc" => 76,
    "daydream-nyregyhza" => 77,
    "daydream-omaha" => 78,
    "daydream-oshkosh" => 79,
    "daydream-ottawa" => 80,
    "daydream-padova" => 81,
    "daydream-penang" => 82,
    "daydream-philippines" => 83,
    "daydream-qena" => 84,
    "daydream-redsea" => 85,
    "daydream-rio-grande-valley" => 86,
    "daydream-so-paulo" => 87,
    "daydream-saugus" => 88,
    "daydream-seattle" => 89,
    "daydream-shelburne" => 90,
    "daydream-silicon-valley" => 91,
    "daydream-south-wales" => 92,
    "daydream-sri-lanka" => 93,
    "daydream-srinagar" => 94,
    "daydream-st-augustine" => 95,
    "daydream-stem-qena" => 96,
    "daydream-sydney" => 97,
    "daydream-taiwan" => 98,
    "daydream-tanta" => 99,
    "daydream-timisoara" => 100,
    "daydream-toronto" => 101,
    "daydream-valencia" => 102,
    "daydream-vancouver" => 103,
    "daydream-visakhapatnam" => 104,
    "daydream-warsaw" => 105,
    "daydream-yaound" => 106,
    "a-really-cool-event" => 107
  }
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dob, presence: true
  validates :address_line_1, presence: true
  validates :address_city, presence: true
  validates :address_state, presence: true
  validates :address_zip_code, presence: true
  validates :address_country, presence: true
  validates :attending_event, presence: true
end
