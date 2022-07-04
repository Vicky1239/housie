require 'securerandom'
class Housie
  NUMBERS_SET = *(1..90)
  COLUMN_SET_1 = *(1..9)
  COLUMN_SET_2 = *(10..19)
  COLUMN_SET_3 = *(20..29)
  COLUMN_SET_4 = *(30..39)
  COLUMN_SET_5 = *(40..49)
  COLUMN_SET_6 = *(50..59)
  COLUMN_SET_7 = *(60..69)
  COLUMN_SET_8 = *(70..79)
  COLUMN_SET_9 = *(80..90)

  SUBSETS = { 1 => COLUMN_SET_1, 2 => COLUMN_SET_2, 3 => COLUMN_SET_3, 4 => COLUMN_SET_4, 5 => COLUMN_SET_5, 6 => COLUMN_SET_6, 7 => COLUMN_SET_7, 8 => COLUMN_SET_8, 9 => COLUMN_SET_9 }

  def print_ticket
    ticket_numbers = select_ticket_numbers  # generate 15 unique numbers to print on ticket as per rules

    # Array dimensions for ticket and default value
    columns, rows, default_value = 9, 3, 'X'
    row_positions = *(1..3)
    ticket = Array.new(rows){Array.new(columns,default_value)}

    # Setting position for selected numbers on the ticket
    ticket_numbers.each do |key, value|
      array_column_index = key - 1  # Column index starts with zero so -1
      # Here array_column_index represents column number and position represents row number for array.

      empty_rows = []

      ticket.each_with_index do |arr, index|
        # check if row has empty space ( max 5 is allowed in each row, so there must be greater than 4 'X')
        empty_rows << index if  arr.select{|val| val == 'X'}.count > 4
      end

      case value.length
      when 1
        position = empty_rows.sample(random: SecureRandom) # returns row number for element in each coulmn
        ticket[position][array_column_index] = value.pop()
      when 2
        positions = empty_rows.sample(2, random: SecureRandom).sort # return row numbers for elements in the column
        value = value.sort # To place values in increasing order.
        2.times do
          ticket[positions.pop()][array_column_index] = value.pop()
        end
      when 3
        value = value.sort
        positions = empty_rows.sort
        3.times do
          ticket[positions.pop()][array_column_index] = value.pop()
        end
      end
    end

    #Printing ticket on console.
    ticket.each do |row|
      puts row.each { |p| p.to_s.ljust(3) }.join("  ")
    end

  end

  def select_ticket_numbers
    selected_numbers = {}
    # As per rule we need to have atleast 1 number in each column
    # so we need to have atleast 1 random number from each column set.
    # Generate 9 mandatory random number, 1 from each small sets.
    9.times do |i|
      value = SUBSETS[i+1].sample(random: SecureRandom)
      selected_numbers[i+1] = [value]  # selecting one of values in each (i+1)th coulmn
    end

    # Now we need to select 15 - 9 = 6 numbers for the ticket
    # These 6 numbers can be any random number from numbers set except the above selected numbers
    search_set = NUMBERS_SET - selected_numbers.values.flatten

    6.times do |i|
      value = search_set.sample(random: SecureRandom)
      key = value / 10 + 1   # finding the key in hash to update selected numbers for the column
      selected_numbers[key] << value  # selecting one of values in each (i+1)th column

      # we need to make sure to not select more than 3 numbers form each subset.
      if selected_numbers[key].length == 3
        search_set = search_set - SUBSETS[key] # Removing the set as we need to select max 3 numbers from any set.
      end
    end

    #We need columns with more numbers first on ticket.
    return selected_numbers.sort_by {|_key, value| -value.length}.to_h # - sign is given to sort in descending order
  end
end

Housie.new.print_ticket
