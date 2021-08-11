SELECT 
       s.[uidMessageID ] as [uidMessageID]
	   ,p.uidPartID
	   ,s.dtTimeStamp
	   ,s.nvcBodyPartName
	   ,mp.nvcPartName
	   ,s.nvcMessageType
	   ,mp.nBodyPart as [IsBodyPart]
	   ,p.nPartSize           as [UncompressedLengthPart]
	   ,DATALENGTH(p.imgPart) as [DatalengthPart]
	   ,p.nNumFragments
	   ,f.nFragmentNumber
	   ,f.nFragmentSize       as [UncompressedLengthFragment]
	   ,DATALENGTH(f.imgFrag) as [DatalengthFragment]
	   ,p.imgPart
	   ,f.imgFrag
FROM [Spool] s WITH(NOLOCK)
LEFT JOIN MessageParts mp WITH(NOLOCK) ON s.[uidMessageID ] = mp.[uidMessageID ]
LEFT JOIN Parts p WITH(NOLOCK) ON mp.uidPartID = p.uidPartID
LEFT JOIN Fragments f WITH(NOLOCK) ON p.uidPartID = f.uidPartID
WHERE 
s.uidBodyPartID is not null -- orphans have null here
--and s.nvcMessageType = 'my-specific-message-type'