<?php

echo date('d/m/y H:i:s');

file_put_contents(__DIR__ . '/test.txt', date('d/m/y H:i:s') . PHP_EOL, FILE_APPEND);
