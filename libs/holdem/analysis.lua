local MAJOR, MINOR = "Holdem:Analysis", 2
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
  return -- no upgrade needed
end
-- Set a reference to the actual package or create an empty table
local Analysis = APkg and APkg.tPackage or {}

local card = Apollo.GetPackage("Holdem:Card").tPackage
local lookup = Apollo.GetPackage("Holdem:Lookup").tPackage
local bit = Apollo.GetPackage("Holdem:Bit").tPackage
local __ = Apollo.GetPackage("Holdem:Underscore").tPackage

local function find(a, tbl)
    for _, a_ in ipairs(tbl) do
        if a_ == a then
            return true
        end
    end
end

local function difference(a, b)
    local ret = {}
    for _,a_ in ipairs(a) do
        if not find(a_, b) then
            table.insert(ret, a_)
        end
    end
    return ret
end

local function card_to_binary5(card)
    local b_mask = bit.lshift(1, (14 + card.rank))
    local cdhs_mask = bit.lshift(1, (card.suit + 11))
    local r_mask = bit.lshift((card.rank - 2), 8)
    local p_mask = lookup.primes[card.rank - 1]
    return bit.bor(b_mask, bit.bor(r_mask, bit.bor(p_mask, cdhs_mask)))
end

local function card_to_binary6(card)
    local b_mask = bit.lshift(1, (14 + card.rank))
    local q_mask = bit.lshift(lookup.primes[card.suit], 12)
    local r_mask = bit.lshift((card.rank - 2), 8)
    local p_mask = lookup.primes[card.rank - 1]
    return bit.bor(b_mask, bit.bor(q_mask, bit.bor(r_mask, p_mask)))
end

local function card_to_binary7(card)
    return card_to_binary6(card)
end

local function card_to_binary_lookup5(card)
    return lookup.Five.card_to_binary[card.rank + 1][card.suit + 1]
end

local function card_to_binary_lookup6(card)
    return lookup.Six.card_to_binary[card.rank + 1][card.suit + 1]
end

local function card_to_binary_lookup7(card)
    return lookup.Seven.card_to_binary[card.rank + 1][card.suit + 1]
end

local function evaluate2(hand)
    if hand[1].suit == hand[2].suit then
        if hand[1].rank < hand[2].rank then
            return nil, lookup.Two.suited_ranks_to_percentile[hand[1].rank+1][hand[2].rank+1]
        else
            return nil, lookup.Two.suited_ranks_to_percentile[hand[2].rank+1][hand[1].rank+1]
        end
    else
        return nil, lookup.Two.unsuited_ranks_to_percentile[hand[1].rank+1][hand[2].rank+1]
    end
end

local function evaluate5(hand)
    local bh = __.map(hand, card_to_binary5)
    local has_flush = __.reduce(bh, 0xF000, bit.band)
    local q = bit.rshift(__.reduce(bh, 0, bit.bor), 16) + 1
    if has_flush > 0 then
        return lookup.Five.flushes[q]
    else
        local possible_rank = lookup.Five.unique5[q]
        if possible_rank ~= 0 then
            return possible_rank
        else
            bh = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            q = __.reduce(bh, 1, function (a, b) return (a * b) end)
            return lookup.Five.pairs[q]
        end
    end
end

local function evaluate6(hand)
    local bh = __.map(hand, card_to_binary6)
    local bhfp = __.map(bh, function (c) return bit.band(bit.rshift(c, 12), 0xF) end)
    local flush_prime = __.reduce(bhfp, 1, function (a, b) return (a * b) end)
    local flush_suit = lookup.Six.prime_products_to_flush[flush_prime]
    local odd_xor = bit.rshift(__.reduce(bh, 0, bit.bxor), 16)
    local even_xor = bit.bxor(bit.rshift(__.reduce(bh, 0, bit.bor), 16), odd_xor)
    if flush_suit then
        if even_xor == 0 then
            local bhflt = __.select(bh, function (e) return bit.band(bit.rshift(e, 12), 0xF) == flush_suit end)
            local bhbits = __.map(bhflt, function (c) return bit.rshift(c, 16) end)
            local bits = __.reduce(bhbits, 0, bit.bor)
            return lookup.Six.flush_rank_bits_to_rank[bits]
        else
            return lookup.Six.flush_rank_bits_to_rank[bit.bor(odd_xor, even_xor)]
        end
    end

    if even_xor == 0 then
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 4 then
            local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
            return lookup.Six.prime_products_to_rank[prime_product]
        else
            return lookup.Six.odd_xors_to_rank[odd_xor]
        end
    elseif odd_xor == 0 then
        local even_popcount = lookup.PopCountTable16(even_xor)
        if even_popcount == 2 then
            local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
            return lookup.Six.prime_products_to_rank[prime_product]
        else
            return lookup.Six.even_xors_to_rank[even_xor]
        end
    else
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 4 then
            return lookup.Six.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
        else
            local even_popcount = lookup.PopCountTable16(even_xor)
            if even_popcount == 2 then
                return lookup.Six.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            else
                local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
                local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
                return lookup.Six.prime_products_to_rank[prime_product]
            end
        end
    end
end

local function evaluate7(hand)
    local bh = __.map(hand, card_to_binary7)
    local bhfp = __.map(bh, function (c) return bit.band(bit.rshift(c, 12), 0xF) end)
    local flush_prime = __.reduce(bhfp, 1, function (a, b) return (a * b) end)
    local flush_suit = lookup.Seven.prime_products_to_flush[flush_prime]
    local odd_xor = bit.rshift(__.reduce(bh, 0, bit.bxor), 16)
    local even_xor = bit.bxor(bit.rshift(__.reduce(bh, 0, bit.bor), 16), odd_xor)
    if flush_suit then
        local even_popcount = lookup.PopCountTable16(even_xor)
        if even_xor == 0 then
            local bhflt = __.select(bh, function (e) return bit.band(bit.rshift(e, 12), 0xF) == flush_suit end)
            local bhbits = __.map(bhflt, function (c) return bit.rshift(c, 16) end)
            local bits = __.reduce(bhbits, 0, bit.bor)
            return lookup.Seven.flush_rank_bits_to_rank[bits]
        else
            if even_popcount == 2 then
                return lookup.Seven.flush_rank_bits_to_rank[bit.bor(odd_xor, even_xor)]
            else
                local bhflt = __.select(bh, function (e) return bit.band(bit.rshift(e, 12), 0xF) == flush_suit end)
                local bhbits = __.map(bhflt, function (c) return bit.rshift(c, 16) end)
                local bits = __.reduce(bhbits, 0, bit.bor)
                return lookup.Seven.flush_rank_bits_to_rank[bits]
            end
        end
    end
    if even_xor == 0 then
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 7 then
            return lookup.Seven.odd_xors_to_rank[odd_xor]
        else
            local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
            return lookup.Seven.prime_products_to_rank[prime_product]
        end
    else
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 5 then
            return lookup.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
        elseif odd_popcount == 3 then
            local even_popcount = lookup.PopCountTable16(even_xor)
            if even_popcount == 2 then
                return lookup.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            else
                local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
                local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
                return lookup.Seven.prime_products_to_rank[prime_product]
            end
        else
            local even_popcount = lookup.PopCountTable16(even_xor)
            if even_popcount == 3 then
                return lookup.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            elseif even_popcount == 2 then
                local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
                local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
                return lookup.Seven.prime_products_to_rank[prime_product]
            else
                return lookup.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            end
        end
    end
end

local function to_cards(h, b)
    local c = {}
    __.each({h, b}, function (t) __.each(t, function (a) table.insert(c, a) end) end)
    return c
end

function Analysis:evaluate(hand, board)
    local ev, cards = nil, to_cards(hand, board)

    local cardset = {}
    for _, c in pairs(cards) do
        local s = c:tostring()
        if not cardset[s] then
            cardset[s] = true
        end
    end

    if #cards == 2 then
        return evaluate2(cards)
    elseif #cards == 5 then
        ev = evaluate5
    elseif #cards == 6 then
        ev = evaluate6
    elseif #cards == 7 then
        ev = evaluate7
    else
        return
    end

    local rank = ev(cards)
    return rank
end

Apollo.RegisterPackage(Analysis, MAJOR, MINOR, {})