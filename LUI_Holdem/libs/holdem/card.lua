local MAJOR, MINOR = "Holdem:Card", 2
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
  return -- no upgrade needed
end
-- Set a reference to the actual package or create an empty table
local Card = APkg and APkg.tPackage or {}

Card = {}
Card.__index = Card
Card.__eq = function (c1, c2)
    return c1:tostring() == c2:tostring()
end

Card.SUIT_TO_STRING = {
        "S",
        "H",
        "D",
        "C"
  }

Card.RANK_TO_STRING = {
         [2] = "2",
         [3] = "3",
         [4] = "4",
         [5] = "5",
         [6] = "6",
         [7] = "7",
         [8] = "8",
         [9] = "9",
        [10] = "T",
        [11] = "J",
        [12] = "Q",
        [13] = "K",
        [14] = "A"
  }

Card.STRING_TO_SUIT = {}
Card.STRING_TO_RANK = {}

for k, v in pairs(Card.SUIT_TO_STRING) do
    Card.STRING_TO_SUIT[v] = k
end

for k, v in pairs(Card.RANK_TO_STRING) do
    Card.STRING_TO_RANK[v] = k
end

setmetatable(Card, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function Card:new(rank, suit)
  local self = setmetatable({}, Card)
    self.rank = rank
    self.suit = suit

    if self.rank < 2 or self.rank > 14 then
      Print("invalid card rank!")
    end

    if self.suit < 1 or self.suit > 4 then
      Print("invalid card suit!")
    end

    return self
end

function Card:tostring()
    return self.RANK_TO_STRING[self.rank]..self.SUIT_TO_STRING[self.suit]
end

Apollo.RegisterPackage(Card, MAJOR, MINOR, {})