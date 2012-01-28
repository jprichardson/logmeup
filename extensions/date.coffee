Date::getUTCTime =  -> this.getTime() + this.getTimezoneOffset() * 60000
  #offsetMinutes = this.getTimezoneOffset()
  #offsetMilliseconds = offsetMinutes * 60 * 1000 #for clarity
  #milleseconds = this.getTime() + offsetMilliseconds