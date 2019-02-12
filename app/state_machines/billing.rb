require_relative 'state_machine'

class StateMachine::Billing

  STATES = [:open, :calculated, :documented, :queued, :delivered, :settled, :void, :closed]

  def self.states
    STATES
  end

  def self.transitions_for(state)
    case state
    when :open
      [:open, :calculated, :void]
    when :calculated
      [:calculated, :documented, :closed, :void]
    when :documented
      [:documented, :queued, :delivered, :void]
    when :queued
      [:queued, :documented, :void]
    when :delivered
      [:delivered, :settled, :void]
    when :settled
      # TODO add transition for reimbursement
      [:closed, :void]
    when :void
      [:void]
    when :closed
      [:closed]
    end
  end

  def self.transition_action(from, to)
    case from
    when :open
      case to
      when :open
        nil
      when :calculated
        :calculate
      when :void
        nil
      end
    when :calculated
      case to
      when :calculated
        nil
      when :documented
        :document
      when :void
        nil
      when :closed
        nil
      end
    when :documented
      case to
      when :documented
        :document
      when :queued
        :queue
      when :delivered
        nil
      when :void
        nil
      end
    when :queued
      case to
      when :queued
        nil
      when :documented
        nil
      when :void
        nil
      end
    when :delivered
      case to
      when :delivered
        nil
      when :settled
        nil
      when :void
        nil
      end
    when :settled
      case to
      when :closed
        nil
      when :void
        # TODO add action for reimbursement
        nil
      end
    when :void
      nil
    when :closed
      nil
    end
  end

end
