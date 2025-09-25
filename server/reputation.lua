exports('getRep',function(src) local id=Framework.identifier(src);local _,_,rep=Storage.get(id);return rep or 0 end)
