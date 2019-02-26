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
      [:queued, :documented, :delivered, :void]
    when :delivered
      [:delivered, :documented, :settled, :void]
    when :settled
      # TODO add transition for reimbursement
      [:closed] #, :void]
    when :void
      [:void]
    when :closed
      [:closed]
    end
  end

  def self.transition_actions(from, to)
    case from
    when :open
      case to
      when :open
        nil
      when :calculated
        [
          {
            action: :calculate,
            at: :pre
          }
        ]
      when :void
        [
          {
            action: :void,
            at: :post
          }
        ]
      end
    when :calculated
      case to
      when :calculated
        nil
      when :documented
        [
          {
            action: :document,
            at: :pre
          }
        ]
      when :void
        [
          {
            action: :reverse,
            at: :post
          },
          {
            action: :void,
            at: :post
          }
        ]
      when :closed
        nil
      end
    when :documented
      case to
      when :documented
        [
          {
            action: :document,
            at: :pre
          }
        ]
      when :queued
        [
          {
            action: :queue,
            at: :post
          }
        ]
      when :delivered
        nil
      when :void
        [
          {
            action: :reverse,
            at: :post
          },
          {
            action: :void,
            at: :post
          }
        ]
      end
    when :queued
      case to
      when :delivered
        nil
      when :queued
        nil
      when :documented
        nil
      when :void
        [
          {
            action: :reverse,
            at: :post
          },
          {
            action: :void,
            at: :post
          }
        ]
      end
    when :delivered
      case to
      when :delivered
        nil
      when :settled
        nil
      when :documented
        nil
      when :void
        [
          {
            action: :reverse,
            at: :post
          },
          {
            action: :void,
            at: :post
          }
        ]
      end
    when :settled
      case to
      when :closed
        nil
      end
    when :void
      nil
    when :closed
      nil
    end
  end

end
