module Watchdog
  class ActivityListener
    
    def self.notify(actor, action, target = nil)
      
      # give point only for uniq and incremental actions
      if actor && action && target && target[:uniq] && !action.to_s.include?("dec")

        point_action = target[:track].tracker

        rules = Settings.points["actions"][point_action]

        point_diff = rules["point"]

        reached_to_next_level = !actor.level.requirements.map { |name, value|
          if name.include?("point")
            
            # calculate point difference between levels after addition
            point_diff = (actor.send(name.to_sym) + rules["point"]) - value

            # mark passed if new point is greater or equal then required
            point_diff >= 0
          else
            actor.send(name.to_sym) >= value
          end
        }.include?(false)

        # reach to the next!
        if reached_to_next_level
          
          next_level = Level.find_by_sequence(actor.level.sequence + 1) || actor.level

          # complete past level if needed
          balance_amount = rules["point"] - point_diff
          if balance_amount > 0

            actor.points.create!(amount: balance_amount, action: point_action, level_id: actor.level.id)          
            # add remaining points to next level
            actor.points.create!(amount: point_diff, action: point_action, level_id: next_level.id)

          # else past level doesn't need any point go straigh into next level   
          else
            actor.points.create!(amount: rules["point"], action: point_action, level_id: next_level.id)
          end

        # or just stay and count
        else
          actor.points.create!(amount: rules["point"], action: point_action, level_id: actor.level.id)          
        end


      end

    end
    
  end
end
