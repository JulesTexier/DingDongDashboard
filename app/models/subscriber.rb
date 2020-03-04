require 'dotenv/load'

class Subscriber < ApplicationRecord

    validates :facebook_id, presence: true
    # validates :email, presence: false, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "email is not valid" }


    has_many :selected_areas
    has_many :areas, through: :selected_areas

    has_many :selected_districts
    has_many :districts, through: :selected_districts

    has_many :favorites
    has_many :fav_properties, through: :favorites, source: :property

    # Rajouter le is_actove: true par défaut

    def get_areas_list
        list = ""
        self.areas.each do |area|
            list = list + ";" + area.name
        end
        list[0] = ''
        return list
    end

    def get_districts_list
        list = ""
        self.districts.each do |district|
            list = list + ";" + district.name
        end
        list[0] = ''
        return list
    end

    def get_edit_path
        return ENV['BASE_URL'] + 'subscribers/' + self.id.to_s + '/edit'
    end


    def is_matching_property?(property)
        test_price = is_matching_property_price(property)
        test_surface = is_matching_property_surface(property)
        test_rooms_number = is_matching_property_rooms_number(property)
        test_floor = is_matching_property_floor(property)
        test_elevator = is_matching_property_elevator_floor(property)
        test_areas = is_matching_property_area(property)

        test_price && test_surface && test_rooms_number && test_floor && test_elevator && test_areas ? true : false
    end

    def get_x_last_props(max_number)
        props = Property.order(id: :desc)
        props_to_send = []

        props.each  do |prop|
            self.is_matching_property?(prop) ? props_to_send.push(prop) : nil

            props_to_send.length == max_number.to_i ? break : nil
        end
        return props_to_send
    end

    def get_props_in_lasts_x_days(x_previous_days)
        t = Time.now
        t.in_time_zone("Europe/Paris")
        start_date = t - x_previous_days.to_i.days

        puts start_date

        props = Property.where('created_at >= ?', start_date)

        props_to_send = []

        props.each  do |prop|
            self.is_matching_property?(prop) ? props_to_send.push(prop) : nil
        end

        return props_to_send
    end

    def get_morning_props

        t = Time.now
        t.in_time_zone("Europe/Paris")
        start_date = t.change(day: t.day - 1, hour: 22)
        end_date = t.change(hour: 9)

        props = Property.where('created_at BETWEEN ? AND ?', start_date, end_date)

        props_to_send = []

        props.each  do |prop|
            self.is_matching_property?(prop) ? props_to_send.push(prop) : nil

            props_to_send.length == 10 ? break : nil
        end
        return props_to_send
    end

    def get_areas
        areas = []
        self.areas.each do |area|
            areas.push(area.name)
        end
        return areas
    end
    
    private 
    
    def is_matching_property_price(property)
       (property.price <= self.max_price ?  true :  false) if !self.max_price.nil?
    end

    def is_matching_property_surface(property)
        (property.surface >= self.min_surface ?  true :  false) if !self.min_surface.nil?
    end

    def is_matching_property_rooms_number(property)
        (property.rooms_number.to_i >= self.min_rooms_number  ?  true :  false) if !self.min_rooms_number.nil?
    end

    def is_matching_property_floor(property)
        if !property.floor.nil?
           (property.floor.to_i >= self.min_floor  ?  true :  false) if !self.min_floor.nil?
        else 
            return true
        end
    end

    def is_matching_property_elevator_floor(property)
        if !property.has_elevator.nil?
            if property.has_elevator 
                return  true 
            else 
                (property.floor.to_i >= self.min_elevator_floor  ?  true :  false) if !self.min_elevator_floor.nil?
            end
        else 
            return true
        end
    end

    def is_matching_property_area(property)
        self.get_areas.include?(property.area) ? true : false
    end


end
