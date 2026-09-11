class AddressPhase < ApplicationRecord
  belongs_to :line_user

  PHASE_ASK_FOR_LAST_NAME = 1
  PHASE_ASK_FOR_FIRST_NAME = 2
  PHASE_ASK_FOR_EMAIL = 3
  PHASE_ASK_FOR_TEL = 4
  PHASE_ASK_FOR_ZIP = 5
  PHASE_ASK_FOR_ADDRESS_STATE = 6
  PHASE_ASK_FOR_ADDRESS_CITY = 7
  PHASE_ASK_FOR_ADDRESS_STREET = 8

  PHASE_CONFIRM_THE_INPUTED_ADDRESS = 9

  PHASE_REVISE_FOR_LAST_NAME = 10
  PHASE_REVISE_FOR_FIRST_NAME = 11
  PHASE_REVISE_FOR_EMAIL = 12
  PHASE_REVISE_FOR_TEL = 13
  PHASE_REVISE_FOR_ZIP = 14
  PHASE_REVISE_FOR_ADDRESS_STATE = 15
  PHASE_REVISE_FOR_ADDRESS_CITY = 16
  PHASE_REVISE_FOR_ADDRESS_STREET = 17

  # Depending on occupation(職種に応じて生じるphase)
  PHASE_ASK_FOR_ROOM_NUMBER = 18
  PHASE_REVISE_FOR_ROOM_NUMBER = 19

  def self.create_address_phase(user)
    find_or_create_by(line_user: user)
  end

  def self.get_my_address_phase(user)
    find_by(line_user: user)
  end

  def self.reset_my_address_phase(user)
    find_by(line_user: user).update!(address_phase: nil)
  end

  def set_my_address_phase(phase)
    update(phase: phase)
  end

end
