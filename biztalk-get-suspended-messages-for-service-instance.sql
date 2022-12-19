SELECT 
       s.[uidMessageID ]      as [uidMessageID]
	   ,p.uidPartID
	   ,s.dtTimeStamp
	   ,s.nvcBodyPartName
	   ,mp.nvcPartName
	   ,s.nvcMessageType
	   ,mp.nBodyPart          as [IsBodyPart]
	   ,p.nPartSize           as [UncompressedLengthPart]
	   ,DATALENGTH(p.imgPart) as [DatalengthPart]
	   ,p.nNumFragments
	   ,f.nFragmentNumber
	   ,f.nFragmentSize       as [UncompressedLengthFragment]
	   ,DATALENGTH(f.imgFrag) as [DatalengthFragment]
	   ,p.imgPart
	   ,f.imgFrag
FROM [Clustered_LongRunning_Orchestration_64Q_Suspended] i WITH (NOLOCK)
INNER JOIN  [Spool] s WITH(NOLOCK) on i.[uidMessageID] = s.[uidMessageID ]
LEFT JOIN MessageParts mp WITH(NOLOCK) ON s.[uidMessageID ] = mp.[uidMessageID ]
LEFT JOIN Parts p WITH(NOLOCK) ON mp.uidPartID = p.uidPartID
LEFT JOIN Fragments f WITH(NOLOCK) ON p.uidPartID = f.uidPartID
WHERE 1=1
-- A specific orchestration or messaging instance, depending on which Q_SUSPENDED we select from.
-- The value can be found in the BizTalk Admin Console:
and i.[uidInstanceID] = 'D89FFAE7-D274-4200-B603-3B0A3AC578E5' 
and s.uidBodyPartID is not null -- orphans have null here
--and s.nvcMessageType = 'my-specific-message-type'
order by s.[uidMessageID ], [nvcBodyPartName], [nvcPartName]
