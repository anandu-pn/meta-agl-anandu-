$sampleRate = 44100;
$duration = 0.5;
$frequency = 880;
$numSamples = [int]($sampleRate * $duration);
$dataSize = $numSamples * 2;
$fileSize = 36 + $dataSize;
$ms = New-Object System.IO.MemoryStream;
$bw = New-Object System.IO.BinaryWriter($ms);
$bw.Write([byte[]]@(0x52,0x49,0x46,0x46));
$bw.Write([int]$fileSize);
$bw.Write([byte[]]@(0x57,0x41,0x56,0x45));
$bw.Write([byte[]]@(0x66,0x6d,0x74,0x20));
$bw.Write([int]16);
$bw.Write([int16]1);
$bw.Write([int16]1);
$bw.Write([int]$sampleRate);
$bw.Write([int]($sampleRate*2));
$bw.Write([int16]2);
$bw.Write([int16]16);
$bw.Write([byte[]]@(0x64,0x61,0x74,0x61));
$bw.Write([int]$dataSize);
for($i=0; $i -lt $numSamples; $i++) {
    $t = $i / $sampleRate;
    $envelope = [Math]::Exp(-$t * 6);
    $val = [Math]::Sin(2 * [Math]::PI * $frequency * $t) * 16000 * $envelope;
    if ($val -gt 32767) { $val = 32767 }
    if ($val -lt -32768) { $val = -32768 }
    $sample = [int16]($val);
    $bw.Write($sample)
};
$bytes = $ms.ToArray();
[System.IO.File]::WriteAllBytes('c:\Users\User\Desktop\projects\meta-agl-anandu-\flutter-app\assets\sounds\notification.wav', $bytes);
$bw.Close();
$ms.Close();
Write-Host 'WAV file created successfully'
